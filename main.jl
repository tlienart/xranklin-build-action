import Pkg

macro g(s, T=String)
    esc(:(
        $(Symbol(s)) = begin
            e = get(ENV, uppercase($s), ""); 
            ($T === String) ? e : parse($T, e)
        end
    ))
end

@g "julia_pre"
@g "python_libs"
@g "branch"
@g "site_folder"
@g "lunr" Bool
@g "lunr_builder"
@g "clear_cache" Bool
@g "base_url_prefix"
@g "preview"
@g "julia_post"

macro i(s)
    include_string(Main, s)
end

# -----------------------------------------------------------------------------
# PRELIM SCRIPT

@i julia_pre

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
        println()
        @info "👀 building the Lunr index..."
        println()
        Pkg.add("NodeJS_16_jll")
        using NodeJS_16_jll
        run(`$(npm) install cheerio`)
        run(`$(npm) install lunr`)
        run(`$(node()) $path_lunr_builder`)
        println()
        @info(" ✔ Lunr index built") 
        println()
    end
end

# -----------------------------------------------------------------------------
# FINAL SCRIPT
@i julia_post

# -----------------------------------------------------------------------------
println("\n🏁🏁🏁 Franklin build process done 🏁🏁🏁\n")