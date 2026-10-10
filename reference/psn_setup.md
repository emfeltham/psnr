# Start Julia and load the package

Starts Julia through JuliaCall in an environment of its own and loads
the shim that translates R data into the arguments of
SamplingPerceivedNetworks.jl. The environment is created on the first
run (this installs the Julia package and its dependencies, which takes a
few minutes) and reused afterwards. It runs once per R session;
[`psn_sample()`](https://emfeltham.github.io/psnr/reference/psn_sample.md)
and
[`psn_inclusion_probs()`](https://emfeltham.github.io/psnr/reference/psn_inclusion_probs.md)
call it automatically.

## Usage

``` r
psn_setup(pkg = NULL)
```

## Arguments

- pkg:

  Where to get SamplingPerceivedNetworks.jl, when the environment is
  created: a URL (`Pkg.add`) or a local directory (`Pkg.develop`). The
  default is the GitHub repository. Giving `pkg` for an existing
  environment reinstalls the Julia package from it.

## Value

`NULL`, invisibly.

## Details

The environment lives in a per-user directory,
`tools::R_user_dir("psnr", "data")`; set
`options(psnr.julia_env = "<dir>")` before the first call to use
another. It is separate from your global Julia environment, so nothing
there needs to change. Julia 1.10 or later must be on the `PATH`.
Because Julia can only be started once per R session, set the option
before any other call starts Julia.

## See also

The Julia package documentation,
<https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.

## Examples

``` r
if (FALSE) { # \dontrun{
psn_setup()

# develop against a local copy of the Julia package
psn_setup(pkg = "~/.julia/dev/SamplingPerceivedNetworks")
} # }
```
