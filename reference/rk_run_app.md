# Launch the interactive risikoR application

Starts the bundled 'shiny' application: four tabs for playing a game
against the AI agents on a clickable map, analysing a single dice duel,
simulating battles against the exact solution, and running strategy
tournaments. Requires the `Suggests` packages the app uses (`shiny` and
`bslib`).

## Usage

``` r
rk_run_app(...)
```

## Arguments

- ...:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Invisible `NULL`. Called for the side effect of launching a Shiny
application.

## Examples

``` r
if (FALSE) { # \dontrun{
rk_run_app()
} # }
```
