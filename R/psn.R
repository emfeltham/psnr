# Thin wrapper: all logic lives in inst/julia/psn_shim.jl and the Julia package.

.psn <- new.env()

#' Start Julia and load the package
#'
#' Starts Julia through JuliaCall in an environment of its own and loads the shim
#' that translates R data into the arguments of SamplingPerceivedNetworks.jl. The
#' environment is created on the first run (this installs the Julia package and
#' its dependencies, which takes a few minutes) and reused afterwards. It runs
#' once per R session; [psn_sample()] and [psn_inclusion_probs()] call it
#' automatically.
#'
#' The environment lives in a per-user directory, `tools::R_user_dir("psnr",
#' "data")`; set `options(psnr.julia_env = "<dir>")` before the first call to use
#' another. It is separate from your global Julia environment, so nothing there
#' needs to change. Julia 1.10 or later must be on the `PATH`. Because Julia can
#' only be started once per R session, set the option before any other call
#' starts Julia.
#'
#' @param pkg Where to get SamplingPerceivedNetworks.jl, when the environment is
#'   created: a URL (`Pkg.add`) or a local directory (`Pkg.develop`). The
#'   default is the GitHub repository. Giving `pkg` for an existing environment
#'   reinstalls the Julia package from it.
#'
#' @return `NULL`, invisibly.
#' @seealso The Julia package documentation,
#'   <https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.
#' @examples
#' \dontrun{
#' psn_setup()
#'
#' # develop against a local copy of the Julia package
#' psn_setup(pkg = "~/.julia/dev/SamplingPerceivedNetworks")
#' }
#' @export
psn_setup <- function(
    pkg = NULL
) {
  if (isTRUE(.psn$ready)) return(invisible())
  julia <- Sys.which("julia")
  if (!nzchar(julia)) stop("Julia (1.10 or later) was not found on the PATH.")
  env <- getOption("psnr.julia_env", file.path(tools::R_user_dir("psnr", "data"), "julia"))

  if (!is.null(pkg) || !file.exists(file.path(env, "Manifest.toml"))) {
    if (is.null(pkg)) pkg <- "https://github.com/human-nature-lab/SamplingPerceivedNetworks.jl"
    local <- dir.exists(pkg)
    if (local) pkg <- normalizePath(pkg)
    dir.create(env, recursive = TRUE, showWarnings = FALSE)
    status <- .julia_run(julia, c(
      "--startup-file=no", paste0("--project=", shQuote(env)),
      shQuote(system.file("julia/psn_env.jl", package = "psnr")),
      shQuote(env), if (local) "path" else "url", shQuote(pkg)))
    if (status != 0) stop("Setting up the Julia environment failed (see output above).")
  }

  Sys.setenv(JULIA_PROJECT = env)
  bindir <- .julia_run(julia, c("--startup-file=no", "-e", shQuote("print(Sys.BINDIR)")), stdout = TRUE)
  JuliaCall::julia_setup(JULIA_HOME = bindir)
  JuliaCall::julia_source(system.file("julia/psn_shim.jl", package = "psnr"))
  .psn$ready <- TRUE
  invisible()
}

# R puts the system library directories on LD_LIBRARY_PATH, and Julia then loads
# the system copies of libraries it bundles (e.g., zstd) and crashes on a version
# mismatch. Run Julia without it.
.julia_run <- function(julia, args, ...) {
  if (.Platform$OS.type == "unix") {
    args <- c("-u", "LD_LIBRARY_PATH", julia, args)
    julia <- "env"
  }
  system2(julia, args, ...)
}

.psn_args <- function(edges, nodes, consents) {
  edges <- as.data.frame(edges)
  list(as.character(edges[[1]]), as.character(edges[[2]]),
       if (!is.null(nodes)) as.character(nodes),
       names(consents), if (!is.null(consents)) as.integer(consents))
}

#' Sampling lists for every perceiver
#'
#' For each person in an unweighted, undirected network, draws a stratified list
#' of real and counterfactual relationships from their social orbit. This calls
#' `samplenetwork` in SamplingPerceivedNetworks.jl; see its documentation for the
#' procedure, the `carryover` rule and the consent rules.
#'
#' @param edges A data frame or matrix whose first two columns are the two
#'   endpoints of each tie (one row per tie). Values are converted to character.
#' @param nodes Optional character vector of all node names. Only needed to
#'   include isolates, which appear in no row of `edges`.
#' @param consents Optional named integer vector of consent codes, with the node
#'   names as names: 0 = none, 1 = survey only, 2 = survey and photo, 3 = photo
#'   only. Every node needs an entry. Only perceivers with code 1 or 2 receive a
#'   list, and a pair is eligible only if both nodes have code 2 or 3.
#' @param desired Optional numeric matrix with one row per degree bin and two
#'   columns: the number of real and of counterfactual pairs to draw.
#' @param dvals Optional list with one element per row of `desired`, giving the
#'   degree(s) in that bin: a single number, or a vector of consecutive degrees
#'   (e.g. `1:2`) to merge several distances into one bin. Give `desired` and
#'   `dvals` together, or neither; with neither, the deployed design is used
#'   (degrees 1 to 4, five real and five counterfactual pairs each).
#' @param seed Integer seed for the Julia random number generator. The default is
#'   drawn from R's generator, so `set.seed()` makes results reproducible.
#' @param shuffle Whether to shuffle each perceiver's list (otherwise sorted).
#' @param carryover Whether a bin that falls short is made up from other bins.
#'
#' @return A data frame with one row per perceiver and pair: `perceiver`, `from`,
#'   `to` (each pair sorted alphanumerically), `bin` (the degree bin, e.g.
#'   `"1:2"` or `"3"`, as a string) and `real` (whether the pair is a tie).
#' @seealso [psn_inclusion_probs()] for the probability that each pair is
#'   listed; the Julia package documentation,
#'   <https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.
#' @examples
#' \dontrun{
#' edges <- data.frame(from = as.character(1:20), to = as.character(c(2:20, 1)))
#' set.seed(1)
#' lists <- psn_sample(edges)
#'
#' # merge degrees 1 and 2 into one bin
#' psn_sample(edges,
#'            desired = rbind(c(10, 10), c(5, 5), c(5, 5)),
#'            dvals = list(1:2, 3, 4))
#' }
#' @export
psn_sample <- function(edges, nodes = NULL, consents = NULL,
                       desired = NULL, dvals = NULL,
                       seed = sample.int(.Machine$integer.max, 1),
                       shuffle = TRUE, carryover = TRUE) {
  psn_setup()
  do.call(JuliaCall::julia_call, c(
    list("psn_sample"), .psn_args(edges, nodes, consents),
    list(desired, dvals, as.integer(seed), shuffle, carryover)))
}

#' Exact inclusion probabilities
#'
#' Computes, without any random sampling, the probability that each pair is on a
#' perceiver's list under [psn_sample()]. Use `1 / pi` as the estimation weight.
#' Arguments are the same as for [psn_sample()] (except `seed` and `shuffle`,
#' which do not matter here). See `inclusionprobs` in SamplingPerceivedNetworks.jl
#' for what the probability does and does not cover.
#'
#' @inheritParams psn_sample
#'
#' @return A data frame with one row for every pair that could be shown to each
#'   perceiver: `perceiver`, `from`, `to`, `bin`, `real` (as in [psn_sample()])
#'   and `pi`, the probability that the pair is on that perceiver's list. Pairs
#'   outside the orbit, or in a bin beyond `dvals`, are not listed (probability
#'   zero).
#' @seealso [psn_sample()]; the Julia package documentation,
#'   <https://human-nature-lab.github.io/SamplingPerceivedNetworks.jl>.
#' @examples
#' \dontrun{
#' edges <- data.frame(from = as.character(1:20), to = as.character(c(2:20, 1)))
#' probs <- psn_inclusion_probs(edges)
#' probs$weight <- 1 / probs$pi
#' }
#' @export
psn_inclusion_probs <- function(edges, nodes = NULL, consents = NULL,
                                desired = NULL, dvals = NULL, carryover = TRUE) {
  psn_setup()
  do.call(JuliaCall::julia_call, c(
    list("psn_inclusionprobs"), .psn_args(edges, nodes, consents),
    list(desired, dvals, carryover)))
}
