import Pkg

"""
    @g "foo" Int

Allocates a variable foo to ENV["FOO"] and type cast it to Int.
"""
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

"""
"""
macro i(s)
    esc(:(include_string(Main, $s)))
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
    prefix=joinpath(base_url_prefix, preview)
)
println()

# -----------------------------------------------------------------------------
# LUNR INDEX

if lunr
    if isfile(joinpath(site_folder, lunr_builder))
        println()
        @info "👀 building the Lunr index..."
        println()
        Pkg.add("NodeJS_16_jll")
        using NodeJS_16_jll
        run(`$(npm) install cheerio`)
        run(`$(npm) install lunr`)
        bk = pwd()
        isempty(site_folder) || cd(site_folder)
        try
            run(`$(node()) $path_lunr_builder`)
            println()
            @info(" ✔ Lunr index built") 
            println()
        catch
            println()
            @info(" 🔴 Lunr index build process failed")
            println()
        finally
            cd(bk)
        end
    else
        println()
        @info(" 🔴 couldn't find the index builder script")
        println()
    end
end

# -----------------------------------------------------------------------------
# FINAL SCRIPT
@i julia_post

# -----------------------------------------------------------------------------
println("\n🏁🏁🏁 Franklin build process done 🏁🏁🏁\n")