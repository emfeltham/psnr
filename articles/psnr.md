# Getting started with psnr

`psnr` generates the sampling lists for collecting cognitive social
structures data: for each person (the perceiver), a stratified set of
real and counterfactual relationships in their social orbit. It calls
the Julia package SamplingPerceivedNetworks.jl, which is documented at
<https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>; read
its guide for the procedure itself. This vignette shows the R calls. It
needs Julia (1.10 or later) and is only evaluated when Julia is found.

## Setup

The first time,
[`psn_setup()`](https://emfeltham.github.io/psnr/reference/psn_setup.md)
creates a Julia environment for `psnr` and installs the Julia package
into it (a few minutes). The other functions call it automatically
afterwards.

``` r

library(psnr)
psn_setup()
```

``` r

library(psnr)
```

## A network

A network is a table of ties, one row per tie. Names can be numbers or
strings; they are converted to character.

``` r

set.seed(1)
g <- igraph::sample_smallworld(1, 100, 3, 0.2)
igraph::V(g)$name <- paste0("p", seq_len(igraph::vcount(g)))
edges <- igraph::as_data_frame(g, what = "edges")
head(edges, 3)
#>   from  to
#> 1   p1  p2
#> 2   p3  p9
#> 3   p4 p76
```

## Lists for every perceiver

With no design given,
[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md)
uses the design fielded in Honduras: for each of degrees 1 to 4, five
real and five counterfactual pairs.

``` r

lists <- psn_sample(edges, nodes = igraph::V(g)$name)
#> Julia version 1.13.1 at location /opt/hostedtoolcache/julia/1.13.1/x64/bin will be used.
#> Loading setup script for JuliaCall...
#> Warning in system2(file.path(.julia$bin_dir, "julia"), shQuote(command), :
#> running command ''/opt/hostedtoolcache/julia/1.13.1/x64/bin/julia'
#> '--startup-file=no'
#> '/home/runner/work/_temp/Library/JuliaCall/julia/install_dependency.jl'
#> '/opt/R/4.6.1/lib/R' 2>&1' had status 139
#> Finish loading setup script for JuliaCall.
head(lists)
#>   perceiver from  to bin  real
#> 1       p19  p13 p30   3  TRUE
#> 2       p19  p20 p79   2  TRUE
#> 3       p19  p25 p92   3 FALSE
#> 4       p19  p24 p66   3  TRUE
#> 5       p19 p100 p11   4  TRUE
#> 6       p19  p18 p21   1  TRUE
table(lists$bin, lists$real)
#>    
#>     FALSE TRUE
#>   1   486  226
#>   2   514  774
#>   3   500  500
#>   4   500  500
```

The result is reproducible with
[`set.seed()`](https://rdrr.io/r/base/Random.html), or with the `seed`
argument.

To check or merge with the true network, note that each pair is sorted
alphanumerically in the same way in `lists`:

``` r

truth <- with(edges, paste(pmin(from, to), pmax(from, to)))
mean(paste(lists$from, lists$to)[lists$real] %in% truth)
#> [1] 1
```

## A different design

`desired` has one row per bin (real, counterfactual) and `dvals` lists
the degrees in each. Consecutive degrees in one element, like `1:2`, are
merged into a single bin:

``` r

merged <- psn_sample(
  edges,
  desired = rbind(c(10, 10), c(5, 5), c(5, 5)),
  dvals = list(1:2, 3, 4)
)
unique(merged$bin)
#> [1] "1:2" "3"   "4"
```

## Consents

`consents` is a named vector of codes (0 = none, 1 = survey only, 2 =
survey and photo, 3 = photo only), with an entry for every node.
Perceivers with code 1 or 2 receive a list, and pairs are limited to
people with code 2 or 3.

``` r

codes <- setNames(sample(0:3, 100, replace = TRUE, prob = c(.1, .2, .5, .2)),
                  igraph::V(g)$name)
with_consent <- psn_sample(edges, consents = codes)
length(unique(with_consent$perceiver))
#> [1] 68
```

## Inclusion probabilities

[`psn_inclusion_probs()`](https://emfeltham.github.io/psnr/reference/psn_inclusion_probs.md)
returns the exact probability, `pi`, that each pair is on a perceiver’s
list, with the same design arguments. Its inverse is the weight for
estimation.

``` r

probs <- psn_inclusion_probs(edges)
probs$weight <- 1 / probs$pi
head(probs)
#>   perceiver from  to bin real        pi   weight
#> 1        p1 p100  p3   1 TRUE 1.0000000 1.000000
#> 2        p1   p3  p5   2 TRUE 0.2727273 3.666667
#> 3        p1   p3  p9   2 TRUE 0.2727273 3.666667
#> 4        p1   p4  p5   2 TRUE 0.2727273 3.666667
#> 5        p1   p4 p76   2 TRUE 0.2727273 3.666667
#> 6        p1   p4 p92   2 TRUE 0.2727273 3.666667
```
