import Pkg

# -----------------------------------------------------------------------------
# PYTHON DEPS

if !isempty(python_libs)
    Pkg.add("PyCall")
    Pkg.build("PyCall")
end

# -----------------------------------------------------------------------------
# XRANKLIN BUILD

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

# -----------------------------------------------------------------------------
# LUNR INDEX

if lunr
    path_lunr_builder = joinpath(site_folder, lunr_builder)
    if isfile(path_lunr_builder)
        print("\n👀 building the Lunr index...")
        Pkg.add("NodeJS_16_jll")
        using NodeJS_16_jll
        run(`$(npm) install cheerio`)
        run(`$(npm) install lunr`)

        run(`$(node()) $path_lunr_builder`)
        println(" (✔ done)") 
    end
end

# -----------------------------------------------------------------------------
println()
println("🏁 build process done 🏁")
println()