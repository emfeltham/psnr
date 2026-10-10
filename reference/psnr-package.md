# psnr: R interface to SamplingPerceivedNetworks.jl

A thin wrapper, through JuliaCall, around the Julia package
SamplingPerceivedNetworks.jl, which implements the distance-based
sampling procedure for cognitive social structures data described in
Feltham, Forastiere and Christakis (2025), "Cognitive representations of
social networks in isolated villages", *Nature Human Behaviour*,
[doi:10.1038/s41562-025-02221-6](https://doi.org/10.1038/s41562-025-02221-6)
.

## Details

Julia 1.10 or later and the Julia package are required; see
[`psn_setup()`](https://emfeltham.github.io/psnr/reference/psn_setup.md).
The main functions are
[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md)
(lists for each perceiver) and
[`psn_inclusion_probs()`](https://emfeltham.github.io/psnr/reference/psn_inclusion_probs.md)
(exact inclusion probabilities). The method itself is documented with
the Julia package:
<https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.

## Author

**Maintainer**: Eric Martin Feltham <eric.feltham@yale.edu>

Authors:

- Eric Martin Feltham <eric.feltham@yale.edu>
