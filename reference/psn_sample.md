# Sampling lists for every perceiver

For each person in an unweighted, undirected network, draws a stratified
list of real and counterfactual relationships from their social orbit.
This calls `samplenetwork` in SamplingPerceivedNetworks.jl; see its
documentation for the procedure, the `carryover` rule and the consent
rules.

## Usage

``` r
psn_sample(
  edges,
  nodes = NULL,
  consents = NULL,
  desired = NULL,
  dvals = NULL,
  seed = sample.int(.Machine$integer.max, 1),
  shuffle = TRUE,
  carryover = TRUE
)
```

## Arguments

- edges:

  A data frame or matrix whose first two columns are the two endpoints
  of each tie (one row per tie). Values are converted to character.

- nodes:

  Optional character vector of all node names. Only needed to include
  isolates, which appear in no row of `edges`.

- consents:

  Optional named integer vector of consent codes, with the node names as
  names: 0 = none, 1 = survey only, 2 = survey and photo, 3 = photo
  only. Every node needs an entry. Only perceivers with code 1 or 2
  receive a list, and a pair is eligible only if both nodes have code 2
  or 3.

- desired:

  Optional numeric matrix with one row per degree bin and two columns:
  the number of real and of counterfactual pairs to draw.

- dvals:

  Optional list with one element per row of `desired`, giving the
  degree(s) in that bin: a single number, or a vector of consecutive
  degrees (e.g. `1:2`) to merge several distances into one bin. Give
  `desired` and `dvals` together, or neither; with neither, the deployed
  design is used (degrees 1 to 4, five real and five counterfactual
  pairs each).

- seed:

  Integer seed for the Julia random number generator. The default is
  drawn from R's generator, so
  [`set.seed()`](https://rdrr.io/r/base/Random.html) makes results
  reproducible.

- shuffle:

  Whether to shuffle each perceiver's list (otherwise sorted).

- carryover:

  Whether a bin that falls short is made up from other bins.

## Value

A data frame with one row per perceiver and pair: `perceiver`, `from`,
`to` (each pair sorted alphanumerically), `bin` (the degree bin, e.g.
`"1:2"` or `"3"`, as a string) and `real` (whether the pair is a tie).

## See also

[`psn_inclusion_probs()`](https://emfeltham.github.io/psnr/reference/psn_inclusion_probs.md)
for the probability that each pair is listed; the Julia package
documentation,
<https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.

## Examples

``` r
if (FALSE) { # \dontrun{
edges <- data.frame(from = as.character(1:20), to = as.character(c(2:20, 1)))
set.seed(1)
lists <- psn_sample(edges)

# merge degrees 1 and 2 into one bin
psn_sample(edges,
           desired = rbind(c(10, 10), c(5, 5), c(5, 5)),
           dvals = list(1:2, 3, 4))
} # }
```
