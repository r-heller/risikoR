# Maintenance record — 30 October 2026

## Purpose and acceptance criteria

Exact combat probabilities, simulation and interactive play for a
documented Risk conquest variant.

The current milestone requires correct supported rules,
bounded/validated inputs, meaningful failure-path regressions, an
installable source package, and a working local app. Original checkouts
and unrelated work are preserved in isolated review branches. No
release, push or deployment is implied by this local record.

## Evidence-led findings and repairs

- High: `R/turn.R` allowed conquest occupation with fewer armies than
  the dice used in the final attack. Recover that count from final
  casualties and require the official minimum while retaining one army
  at the source. Independent one-, two- and three-dice boundary cases
  protect the rule.
- Medium: shared numeric checks and reinforcement/fortification
  arithmetic accepted non-finite values or overflowed. Validate whole
  counts and bounds before mutation/coercion; preserve the input game.
- Documentation: explicitly list the omitted cards, missions and printed
  two-player neutral setup rather than imply a complete official rules
  implementation.

Rule source checked:
<https://www.hasbro.com/common/instruct/Risk_World_Conquest_Game.pdf>

## Roadmap and completion

1.  Essential repairs: correct the confirmed rule/process defects above
    and protect them with independent boundary cases. Implemented and
    locally validated.
2.  Everyday use: preserve user state, validate invalid inputs, install
    the package, exercise play/analysis and the app. Completed for the
    paths below.
3.  Release preparation: synchronize documentation and package checks.
    Local candidate prepared; platform CI and maintainer publication
    review remain.
4.  Deferred enhancements: retain the focused supported model; do not
    add engines, rule variants or infrastructure without an explicit use
    case and validation.

## Actual verification

R 4.6.1 on ARM64 macOS, 30 October 2026:

- Full source tests: 631 assertions passed. Full packaged tests with
  vignettes: 623 assertions, 6 conditional skips, no failures. That
  check reported one namespace note for `tail`; qualified it as
  [`utils::tail`](https://rdrr.io/r/utils/head.html) and reran
  packaging/checks **Status OK** with `--no-tests` after the complete
  passing suite above.
- Installed journey: all 42 territories, 60 legal actions, army
  accounting, and independently enumerated 15/36 one-die odds passed.
- Installed browser app: map/reset, 3-vs-2 duel table, battle histogram
  (100 simulations) and strategy comparison (2 games, 5 rounds) passed
  with no page errors.

Exact command results and logs are retained locally in
`/Users/rh/Documents/GitHub/.repository-audit/2026-10-30-rheller-refinement/risikoR/`.
Failures preceding fixes remain there alongside the final evidence.

## First use from this checkout

Install R (tested with 4.6.1). For compiled dependencies use Xcode
command-line tools on macOS, Rtools on Windows, or the matching Linux
C/C++ toolchain. From this repository, install dependencies and the
local candidate:

``` sh
Rscript --vanilla -e 'install.packages("remotes", repos="https://cloud.r-project.org"); remotes::install_local(".", dependencies=TRUE, upgrade="never", build_vignettes=FALSE)'
Rscript --vanilla -e 'risikoR::rk_run_app()'
```

Open the local URL printed by Shiny. The README gives the scriptable
workflow. To repeat source tests, run
`Rscript --vanilla -e 'pkgload::load_all(); testthat::test_local(stop_on_failure=TRUE)'`
after installing the development dependencies.

## Limits and next release action

The whole-game model is a conquest variant. Card trading, secret
missions and the printed two-player neutral setup are deferred; they
require an explicit rules-design milestone. Native Windows/Linux and
hosted CI were not run.

Review the local diff and run required platform CI on the chosen release
commit; then decide whether to publish. No hosted result or external
acceptance is claimed.
