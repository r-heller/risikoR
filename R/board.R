# Board geometry: turn a map's point layout into a tiled landmass.
#
# Territories are drawn as clusters of hexagonal cells rather than as points.
# Cells are claimed by the nearest territory centre, land bridges are grown
# along short adjacency links so that neighbours share a border, and a channel
# is carved wherever the two closest territories do not in fact border one
# another. Everything is derived from `layout` and `adjacency`, so custom maps
# built with [rk_map()] get the same treatment as the world board.

# Cached because the geometry is deterministic and the world board is drawn
# again on every Shiny redraw.
.rk_board_cache <- new.env(parent = emptyenv())

.rk_board <- function(map) {
  key <- .rk_board_key(map)
  hit <- .rk_board_cache[[key]]
  if (!is.null(hit)) {
    return(hit)
  }
  board <- .rk_build_board(map)
  if (length(ls(.rk_board_cache)) > 8L) {
    rm(list = ls(.rk_board_cache), envir = .rk_board_cache)
  }
  assign(key, board, envir = .rk_board_cache)
  board
}

.rk_board_key <- function(map) {
  paste(
    paste(map$territories, collapse = "\r"),
    paste(round(map$layout$x, 6), round(map$layout$y, 6), collapse = "\r"),
    paste(lengths(map$adjacency), collapse = "\r"),
    sep = "\n"
  )
}

# Scale every tiling constant off the typical distance between neighbours so
# that the same code works for the world board and for a four-territory toy.
.rk_board_scale <- function(map) {
  links <- .rk_links(map)
  step <- stats::median(links$d)
  if (!is.finite(step) || step <= 0) {
    step <- max(diff(range(map$layout$x)), diff(range(map$layout$y))) / 6
  }
  size <- 0.055 * step
  list(
    size = size,             # hex circumradius
    radius = 0.58 * step,    # how far a territory reaches from its centre
    bridge_w = 0.19 * step,  # half-width of a land bridge
    bridge_max = 1.55 * step, # longer links stay sea routes
    # The channel between non-neighbours has to be wider than one row of cells
    # or it can fall between cell centres and separate nothing at all.
    channel = max(0.10 * step, 2.4 * size),
    # A link this much longer than the typical one is a wrap around the far side
    # of the board; drawn as an arc it would sweep across everything.
    wrap_min = 3 * step,
    step = step
  )
}

# Undirected adjacency links with their endpoints and lengths.
.rk_links <- function(map) {
  from <- rep(names(map$adjacency), lengths(map$adjacency))
  to <- unlist(map$adjacency, use.names = FALSE)
  keep <- from < to
  from <- from[keep]
  to <- to[keep]
  lay <- map$layout
  i <- match(from, lay$territory)
  j <- match(to, lay$territory)
  tibble::tibble(
    from = from, to = to,
    x = lay$x[i], y = lay$y[i], xend = lay$x[j], yend = lay$y[j],
    d = sqrt((lay$x[i] - lay$x[j])^2 + (lay$y[i] - lay$y[j])^2)
  )
}

# Distance from points to a line segment.
.rk_seg_dist <- function(px, py, ax, ay, bx, by) {
  vx <- bx - ax
  vy <- by - ay
  len2 <- vx * vx + vy * vy
  t <- if (len2 <= 0) 0 else ((px - ax) * vx + (py - ay) * vy) / len2
  t <- pmin(1, pmax(0, t))
  sqrt((px - ax - t * vx)^2 + (py - ay - t * vy)^2)
}

# Index of the six neighbours of every cell on an odd-r offset hex grid.
.rk_hex_neighbours <- function(col, row) {
  key <- paste(col, row)
  odd <- row %% 2 == 1
  o1 <- list(c(1, 0), c(-1, 0), c(0, 1), c(0, -1), c(1, 1), c(1, -1))
  o0 <- list(c(1, 0), c(-1, 0), c(-1, 1), c(-1, -1), c(0, 1), c(0, -1))
  out <- matrix(NA_integer_, length(col), 6L)
  for (k in 1:6) {
    dc <- ifelse(odd, o1[[k]][1], o0[[k]][1])
    dr <- ifelse(odd, o1[[k]][2], o0[[k]][2])
    out[, k] <- match(paste(col + dc, row + dr), key)
  }
  out
}

.rk_cells <- function(map, cfg) {
  lay <- map$layout
  w <- sqrt(3) * cfg$size
  h <- 1.5 * cfg$size
  pad <- cfg$radius + 3 * cfg$size
  xr <- range(lay$x) + c(-pad, pad)
  yr <- range(lay$y) + c(-pad, pad)
  col <- seq.int(0L, ceiling(diff(xr) / w))
  row <- seq.int(0L, ceiling(diff(yr) / h))
  grid <- expand.grid(col = col, row = row)
  cx <- xr[[1L]] + w * (grid$col + 0.5 * (grid$row %% 2))
  cy <- yr[[1L]] + h * grid$row

  d <- sqrt(outer(cx, lay$x, "-")^2 + outer(cy, lay$y, "-")^2)
  n <- nrow(d)
  i1 <- max.col(-d, ties.method = "first")
  d1 <- d[cbind(seq_len(n), i1)]
  d[cbind(seq_len(n), i1)] <- Inf
  i2 <- max.col(-d, ties.method = "first")
  d2 <- d[cbind(seq_len(n), i2)]
  t1 <- lay$territory[i1]
  t2 <- lay$territory[i2]

  land <- d1 <= cfg$radius
  links <- .rk_links(map)
  short <- links[links$d <= cfg$bridge_max, ]
  for (k in seq_len(nrow(short))) {
    land <- land | .rk_seg_dist(
      cx, cy, short$x[[k]], short$y[[k]], short$xend[[k]], short$yend[[k]]
    ) <= cfg$bridge_w
  }
  neighbours <- mapply(
    function(a, b) b %in% map$adjacency[[a]], t1, t2, USE.NAMES = FALSE
  )
  keep <- land & (neighbours | (d2 - d1) > cfg$channel)

  keep <- .rk_fill_lakes(keep, grid$col, grid$row)
  tibble::tibble(
    cell = which(keep), territory = t1[keep], x = cx[keep], y = cy[keep]
  )
}

# Close enclosed pockets of at most three cells; larger ones stay as inland
# seas, and channels that reach open water stay open.
.rk_fill_lakes <- function(keep, col, row) {
  nb <- .rk_hex_neighbours(col, row)
  border <- col == min(col) | col == max(col) |
    row == min(row) | row == max(row)
  open <- border & !keep
  repeat {
    grow <- unique(as.vector(nb[open, , drop = FALSE]))
    grow <- grow[!is.na(grow)]
    grow <- grow[!keep[grow] & !open[grow]]
    if (length(grow) == 0L) break
    open[grow] <- TRUE
  }
  lake <- !keep & !open
  if (!any(lake)) {
    return(keep)
  }
  comp <- rep(NA_integer_, length(lake))
  group <- 0L
  for (start in which(lake)) {
    if (!is.na(comp[[start]])) next
    group <- group + 1L
    comp[[start]] <- group
    front <- start
    while (length(front) > 0L) {
      nxt <- unique(as.vector(nb[front, , drop = FALSE]))
      nxt <- nxt[!is.na(nxt)]
      nxt <- nxt[lake[nxt] & is.na(comp[nxt])]
      comp[nxt] <- group
      front <- nxt
    }
  }
  sizes <- table(comp)
  small <- as.integer(names(sizes)[sizes <= 3L])
  keep | (!is.na(comp) & comp %in% small)
}

# Hexagon corners, six rows per cell, in drawing order.
.rk_tiles <- function(cells, cfg) {
  ang <- (90 + 60 * (0:5)) * pi / 180
  n <- nrow(cells)
  tibble::tibble(
    cell = rep(cells$cell, each = 6L),
    territory = rep(cells$territory, each = 6L),
    x = rep(cells$x, each = 6L) + cfg$size * cos(rep(ang, n)),
    y = rep(cells$y, each = 6L) + cfg$size * sin(rep(ang, n))
  )
}

# Every hexagon edge, tagged with the cell it came from.
.rk_cell_edges <- function(tiles, cells) {
  n <- nrow(cells)
  i <- seq_len(n)
  head <- rep((i - 1L) * 6L, each = 6L) + rep(1:6, n)
  tail <- rep((i - 1L) * 6L, each = 6L) + rep(c(2:6, 1L), n)
  x <- round(tiles$x[head], 6)
  y <- round(tiles$y[head], 6)
  xend <- round(tiles$x[tail], 6)
  yend <- round(tiles$y[tail], 6)
  a <- paste(x, y)
  b <- paste(xend, yend)
  tibble::tibble(
    x = x, y = y, xend = xend, yend = yend,
    cx = rep(cells$x, each = 6L), cy = rep(cells$y, each = 6L),
    territory = tiles$territory[head],
    id = paste(pmin(a, b), pmax(a, b))
  )
}

# Nudge a segment towards the centre of the cell it belongs to, so that a
# border between two continents can be drawn in both their colours.
.rk_nudge <- function(seg, by) {
  mx <- (seg$x + seg$xend) / 2
  my <- (seg$y + seg$yend) / 2
  dx <- seg$cx - mx
  dy <- seg$cy - my
  len <- sqrt(dx^2 + dy^2)
  len[len <= 0] <- 1
  seg$x <- seg$x + by * dx / len
  seg$xend <- seg$xend + by * dx / len
  seg$y <- seg$y + by * dy / len
  seg$yend <- seg$yend + by * dy / len
  seg
}

.rk_build_board <- function(map) {
  cfg <- .rk_board_scale(map)
  cells <- .rk_cells(map, cfg)
  terr_cont <- .rk_territory_continent(map)
  cells$continent <- unname(terr_cont[cells$territory])

  tiles <- .rk_tiles(cells, cfg)
  tiles$continent <- unname(terr_cont[tiles$territory])

  edges <- .rk_cell_edges(tiles, cells)
  edges$continent <- unname(terr_cont[edges$territory])
  dup <- edges$id %in% edges$id[duplicated(edges$id)]

  # An edge shared by two cells of the same territory is interior; shared by
  # two territories it is a border; unshared it is coastline. A border between
  # two continents is drawn once in each continent's colour.
  same_terr <- duplicated(paste(edges$id, edges$territory)) |
    duplicated(paste(edges$id, edges$territory), fromLast = TRUE)
  same_cont <- duplicated(paste(edges$id, edges$continent)) |
    duplicated(paste(edges$id, edges$continent), fromLast = TRUE)

  # Both copies of a border are kept and nudged towards their own cell, so each
  # side can be drawn in a colour that survives its own fill: a white crease
  # disappears on a pale territory, a dark one disappears on a saturated one.
  borders <- .rk_nudge(edges[!same_terr & dup, ], 0.18 * cfg$size)
  coast <- rbind(
    edges[!dup, ],
    .rk_nudge(edges[dup & !same_cont, ], 0.22 * cfg$size)
  )

  # Territory pairs whose tiles share an edge really do border on the map.
  shared <- edges[dup & !same_terr, ]
  pair <- unique(vapply(
    split(shared$territory, shared$id),
    function(z) paste(sort(unique(z)), collapse = "\r"),
    character(1L)
  ))

  centres <- .rk_centres(cells)
  links <- .rk_links(map)
  links$touch <- paste(pmin(links$from, links$to),
                       pmax(links$from, links$to), sep = "\r") %in% pair

  links$wrap <- !links$touch & links$d > cfg$wrap_min

  list(
    cfg = cfg,
    cells = cells,
    tiles = tiles,
    borders = borders[, c("x", "y", "xend", "yend", "territory")],
    coast = coast[, c("x", "y", "xend", "yend", "continent")],
    routes = .rk_routes(links, cells, centres, cfg),
    wraps = .rk_wraps(links, cells, cfg),
    centres = centres,
    labels = .rk_continent_labels(map, cells)
  )
}

# The cell of `territory` that lies closest to the point (x, y), pushed a little
# way offshore so a route drawn from it starts in the water.
.rk_landfall <- function(cells, territory, x, y, out) {
  d <- cells[cells$territory == territory, ]
  i <- which.min((d$x - x)^2 + (d$y - y)^2)
  px <- d$x[[i]]
  py <- d$y[[i]]
  len <- sqrt((x - px)^2 + (y - py)^2)
  if (len <= 0) {
    return(c(px, py))
  }
  c(px + out * (x - px) / len, py + out * (y - py) / len)
}

# Label anchor for each territory: the mean of its cells, nudged to the cell
# closest to that mean so the anchor always sits on land.
.rk_centres <- function(cells) {
  out <- lapply(split(cells, cells$territory), function(d) {
    mx <- mean(d$x)
    my <- mean(d$y)
    i <- which.min((d$x - mx)^2 + (d$y - my)^2)
    tibble::tibble(
      territory = d$territory[[1L]],
      x = (mx + d$x[[i]]) / 2, y = (my + d$y[[i]]) / 2,
      span = diff(range(d$x))
    )
  })
  do.call(rbind, out)
}

# Sea routes: links between neighbours whose land does not meet. Drawn from
# coast to coast rather than centre to centre -- a route that starts under a
# territory's own label reads as a stray mark -- and bowed away from the middle
# of the board so it stays out over the water.
.rk_routes <- function(links, cells, centres, cfg, n = 40L) {
  empty <- tibble::tibble(
    id = integer(0), x = numeric(0), y = numeric(0)
  )
  sea <- links[!links$touch & !links$wrap, ]
  if (nrow(sea) == 0L) {
    return(empty)
  }
  mx <- mean(centres$x)
  my <- mean(centres$y)
  t <- seq(0, 1, length.out = n)
  out <- lapply(seq_len(nrow(sea)), function(k) {
    i <- match(sea$from[[k]], centres$territory)
    j <- match(sea$to[[k]], centres$territory)
    a <- .rk_landfall(cells, sea$from[[k]], centres$x[[j]], centres$y[[j]],
                      1.4 * cfg$size)
    b <- .rk_landfall(cells, sea$to[[k]], centres$x[[i]], centres$y[[i]],
                      1.4 * cfg$size)
    len <- sqrt((b[[1L]] - a[[1L]])^2 + (b[[2L]] - a[[2L]])^2)
    if (len <= 0) {
      return(NULL)
    }
    px <- -(b[[2L]] - a[[2L]]) / len
    py <- (b[[1L]] - a[[1L]]) / len
    midx <- (a[[1L]] + b[[1L]]) / 2
    midy <- (a[[2L]] + b[[2L]]) / 2
    sgn <- sign((midx - mx) * px + (midy - my) * py)
    if (sgn == 0) sgn <- 1
    # Short routes need proportionally more bow or they read as a wobble in the
    # coastline rather than as a crossing.
    bow <- sgn * max(0.22 * len, 2.6 * cfg$size)
    tibble::tibble(
      id = k,
      x = (1 - t)^2 * a[[1L]] + 2 * (1 - t) * t * (midx + bow * px) +
        t^2 * b[[1L]],
      y = (1 - t)^2 * a[[2L]] + 2 * (1 - t) * t * (midy + bow * py) +
        t^2 * b[[2L]]
    )
  })
  do.call(rbind, out)
}

# Wrap links join territories on opposite sides of the board -- Alaska and
# Kamchatka face each other across the Pacific, not across Europe. An arc would
# sweep over half the map, so each end gets a short stub running off its own
# edge, the way a printed board does it.
.rk_wraps <- function(links, cells, cfg) {
  empty <- tibble::tibble(
    id = integer(0), x = numeric(0), y = numeric(0), label = character(0)
  )
  wrap <- links[links$wrap, ]
  if (nrow(wrap) == 0L) {
    return(empty)
  }
  xr <- range(cells$x)
  mid <- mean(xr)
  reach <- 0.55 * cfg$step
  out <- lapply(seq_len(nrow(wrap)), function(k) {
    ends <- c(wrap$from[[k]], wrap$to[[k]])
    do.call(rbind, lapply(seq_along(ends), function(e) {
      d <- cells[cells$territory == ends[[e]], ]
      side <- if (mean(d$x) < mid) -1 else 1
      i <- if (side < 0) which.min(d$x) else which.max(d$x)
      x0 <- d$x[[i]] + side * 1.2 * cfg$size
      y0 <- d$y[[i]]
      tibble::tibble(
        id = 2L * k - 2L + e,
        x = c(x0, x0 + side * reach),
        y = c(y0, y0),
        label = ends[[if (e == 1L) 2L else 1L]]
      )
    }))
  })
  do.call(rbind, out)
}

# Continent names go in open water. Nearness to the continent's centroid is not
# enough on its own: on the world board it put "ASIA" and "AUSTRALIA" side by
# side in the same empty gutter, each closer to the other's coast than to its
# own. So a candidate spot only counts if the land nearest to it belongs to the
# continent being labelled, and the whole width of the label has to stay clear
# of land, not just its centre.
.rk_continent_labels <- function(map, cells) {
  span <- max(diff(range(cells$x)), diff(range(cells$y)))
  clear <- 0.035 * span
  pitch <- 0.012 * span
  gx <- seq(min(cells$x) - clear * 2, max(cells$x) + clear * 2, by = pitch)
  gy <- seq(min(cells$y) - clear * 2, max(cells$y) + clear * 2, by = pitch)
  grid <- expand.grid(x = gx, y = gy)
  near <- .rk_nearest_land(grid$x, grid$y, cells)
  grid$owner <- near$continent
  grid <- grid[near$d > clear, , drop = FALSE]

  out <- lapply(names(map$continent), function(cn) {
    d <- cells[cells$continent == cn, ]
    if (nrow(d) == 0L) {
      return(NULL)
    }
    cx <- mean(d$x)
    cy <- mean(d$y)
    label <- paste0(
      toupper(gsub("_", " ", cn)), "  +", map$continent_bonus[[cn]]
    )
    half <- 0.0072 * span * nchar(label)
    cand <- grid[grid$owner == cn, , drop = FALSE]
    if (nrow(cand) > 0L) {
      ok <- rep(TRUE, nrow(cand))
      for (offset in seq(-half, half, length.out = 7L)) {
        ok <- ok &
          .rk_nearest_land(cand$x + offset, cand$y, cells)$d > clear * 0.75
      }
      if (any(ok)) {
        cand <- cand[ok, , drop = FALSE]
      }
    }
    if (nrow(cand) == 0L) {
      # Nowhere in open water is nearest to this continent: fall back to just
      # below its own southern edge.
      return(tibble::tibble(
        continent = cn, x = cx, y = min(d$y) - clear, label = label
      ))
    }
    i <- which.min((cand$x - cx)^2 + (cand$y - cy)^2)
    tibble::tibble(
      continent = cn, x = cand$x[[i]], y = cand$y[[i]], label = label
    )
  })
  do.call(rbind, out)
}

# Distance to the nearest land cell, and which continent that cell belongs to.
.rk_nearest_land <- function(px, py, cells) {
  qx <- cells$x
  qy <- cells$y
  cont <- cells$continent
  # Thin the reference points: the clearance test only needs to be about right,
  # but keep at least a few cells of every continent so the owner stays honest.
  if (length(qx) > 1200L) {
    take <- unlist(lapply(split(seq_along(qx), cont), function(idx) {
      idx[unique(round(seq(1L, length(idx),
                          length.out = max(2L, round(1200 * length(idx) /
                                                       length(qx))))))]
    }), use.names = FALSE)
    qx <- qx[take]
    qy <- qy[take]
    cont <- cont[take]
  }
  d <- numeric(length(px))
  owner <- character(length(px))
  for (idx in split(seq_along(px), ceiling(seq_along(px) / 600))) {
    m <- outer(px[idx], qx, "-")^2 + outer(py[idx], qy, "-")^2
    j <- max.col(-m, ties.method = "first")
    d[idx] <- sqrt(m[cbind(seq_along(idx), j)])
    owner[idx] <- cont[j]
  }
  list(d = d, continent = owner)
}

# Circle outlines in data units, so chips scale with the board rather than
# with the device.
.rk_discs <- function(x, y, r, n = 24L) {
  ang <- seq(0, 2 * pi, length.out = n + 1L)[-(n + 1L)]
  k <- length(x)
  tibble::tibble(
    id = rep(seq_len(k), each = n),
    x = rep(x, each = n) + r * cos(rep(ang, k)),
    y = rep(y, each = n) + r * sin(rep(ang, k))
  )
}
