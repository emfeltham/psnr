# psn_env.jl
# Run by psn_setup() in a separate Julia process: ARGS = (env dir, kind, source),
# where kind is "url" or "path". Creates the Julia environment psnr runs in.
import Pkg
env, kind, src = ARGS
Pkg.activate(env)
# RCall and Suppressor are needed by JuliaCall; the rest by psn_shim.jl
Pkg.add(["RCall", "Suppressor", "Graphs", "MetaGraphs", "DataFrames", "Random"])
kind == "path" ? Pkg.develop(path = src) : Pkg.add(url = src)
Pkg.precompile()
