# psn_shim.jl
# Translates plain R data (vectors, matrices, data frames) into the arguments
# SamplingPerceivedNetworks expects. Sampling, inclusion probabilities, design
# defaults and flattening to an edgelist are all the package's own functions.

using SamplingPerceivedNetworks, Graphs, MetaGraphs, Random, DataFrames

# edgelist (+ optional isolates) -> MetaGraph with :name, indexed by name
function _psn_graph(from, to, nodes)
    from, to = String.(from), String.(to)
    names = unique(vcat(nodes === nothing ? String[] : String.(nodes), from, to))
    g = MetaGraph(length(names))
    for (i, nm) in enumerate(names)
        set_prop!(g, i, :name, nm)
    end
    set_indexing_prop!(g, :name)
    for (a, b) in zip(from, to)
        a == b || add_edge!(g, g[a, :name], g[b, :name])
    end
    return g
end

_psn_consents(names, codes) =
    names === nothing ? nothing : Dict{String, Int}(String.(names) .=> Int.(codes))

# NULL -> deployed design; n x 2 matrix -> tuples; c(a, b) -> a:b
function _psn_spec(desired, dvals)
    desired === nothing && dvals === nothing && return deployed_design
    (desired === nothing) == (dvals === nothing) ||
        throw(ArgumentError("give both desired and dvals, or neither"))
    des = Tuple.(eachrow(Int.(desired)))
    dv = map(dvals) do x
        x isa Integer && return Int(x)
        r = Int.(x)
        length(r) == 1 && return r[1]
        r == collect(r[1]:r[end]) ||
            throw(ArgumentError("dvals ranges must be consecutive integers"))
        r[1]:r[end]
    end
    return (desired = des, dvals = Tuple(dv))
end

function psn_sample(from, to, nodes, consent_names, consent_codes,
                    desired, dvals, seed, shuffle, carryover)
    g = _psn_graph(from, to, nodes)
    cons = _psn_consents(consent_names, consent_codes)
    spec = _psn_spec(desired, dvals)
    args = cons === nothing ? (g,) : (g, cons)
    lists = samplenetwork(Xoshiro(seed), args...; spec...,
                          moreinfo = true, shuffle = shuffle, carryover = carryover)
    return psn_edgelists(lists)
end

function psn_inclusionprobs(from, to, nodes, consent_names, consent_codes,
                            desired, dvals, carryover)
    g = _psn_graph(from, to, nodes)
    cons = _psn_consents(consent_names, consent_codes)
    return inclusionprobs(g, cons; _psn_spec(desired, dvals)..., carryover = carryover)
end
