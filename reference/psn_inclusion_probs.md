# Exact inclusion probabilities

Computes, without any random sampling, the probability that each pair is
on a perceiver's list under
[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md).
Use `1 / pi` as the estimation weight. Arguments are the same as for
[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md)
(except `seed` and `shuffle`, which do not matter here). See
`inclusionprobs` in SamplingPerceivedNetworks.jl for what the
probability does and does not cover.

## Usage

``` r
psn_inclusion_probs(
  edges,
  nodes = NULL,
  consents = NULL,
  desired = NULL,
  dvals = NULL,
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

- carryover:

  Whether a bin that falls short is made up from other bins.

## Value

A data frame with one row for every pair that could be shown to each
perceiver: `perceiver`, `from`, `to`, `bin`, `real` (as in
[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md))
and `pi`, the probability that the pair is on that perceiver's list.
Pairs outside the orbit, or in a bin beyond `dvals`, are not listed
(probability zero).

## See also

[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md);
the Julia package documentation,
<https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.

## Examples

``` r
if (FALSE) { # \dontrun{
edges <- data.frame(from = as.character(1:20), to = as.character(c(2:20, 1)))
probs <- psn_inclusion_probs(edges)
probs$weight <- 1 / probs$pi
} # }
```
