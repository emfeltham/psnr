# psnr

A thin R interface to [SamplingPerceivedNetworks.jl](https://github.com/human-nature-lab/SamplingPerceivedNetworks.jl), the distance-based sampling procedure for cognitive social structures data (Feltham, Forastiere & Christakis 2025, *Nature Human Behaviour*, <https://doi.org/10.1038/s41562-025-02221-6>).

The R side only passes data to Julia through [JuliaCall](https://cran.r-project.org/package=JuliaCall). The logic lives in the Julia package; `inst/julia/psn_shim.jl` translates R data frames and vectors into its arguments.

## Installation

Requires Julia 1.10 or later on the `PATH`, and the R package `JuliaCall`.

```r
remotes::install_github("human-nature-lab/psnr")  # adjust to wherever this repo is hosted
psnr::psn_setup()
```

`psn_setup()` creates a Julia environment of its own (under `tools::R_user_dir("psnr", "data")`) and installs SamplingPerceivedNetworks.jl and its dependencies into it on the first run, which takes a few minutes. Your global Julia environment is not touched. To use a local copy of the Julia package instead of the GitHub version, run `psn_setup(pkg = "path/to/SamplingPerceivedNetworks")`. The other functions call `psn_setup()` for you in later sessions.

## Usage

```r
library(psnr)

edges <- data.frame(from = as.character(1:20), to = as.character(c(2:20, 1)))

lists <- psn_sample(edges, seed = 1)   # lists of real and counterfactual pairs
probs <- psn_inclusion_probs(edges)    # exact inclusion probabilities; weight = 1 / pi
```

See `vignette("psnr")` for a worked example (custom designs, consents,
weights) and `?psn_sample` for the arguments. The method itself (orbits, bins,
carry-over, consent rules) is documented with the Julia package:
<https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.
