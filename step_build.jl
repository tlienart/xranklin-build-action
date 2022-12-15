import Pkg

if !isempty(python_libs)
    Pkg.add("PyCall")
    Pkg.build("PyCall")
end

Pkg.add(
    url="https://github.com/tlienart/Xranklin.jl",
    rev=branch
)
using Xranklin
build(
    site_folder;
    clear=clear_cache,
    prefix=joinpath(
        base_prefix,
        preview
    )
)
println()

if lunr && isfile(lunr_builder)
    include("step_lunr.jl")
end