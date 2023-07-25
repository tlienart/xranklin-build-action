import Pkg

"""
    @g "foo" [T]

Allocates a variable foo to ENV["FOO"] and type cast it to T if
given (otherwise a String is returned).
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
@g "site_folder"
@g "lunr" Bool
@g "lunr_builder"
@g "base_url_prefix"
@g "preview"
@g "julia_post"
@g "franklin_repo"
@g "franklin_version"
@g "franklin_branch"


"""
    @i code

Evaluate Julia code in the current environment.
"""
macro i(s)
    esc(:(include_string(Main, $s)))
end

# -----------------------------------------------------------------------------
# PRELIM SCRIPT
println("-------------------------------------------")
println("🏁🏁🏁 Starting Franklin build process 🏁🏁🏁")
println("-------------------------------------------")
@i julia_pre

# -----------------------------------------------------------------------------
# PYTHON DEPS
if !isempty(python_libs)
    Pkg.add("PyCall")
    Pkg.build("PyCall")
end

# -----------------------------------------------------------------------------
# XRANKLIN BUILD
Pkg.add("Reexport") # should have to be explicitly done but seems to help
if !isempty(franklin_version) && franklin_branch == "main"
    Pkg.add(
        url=franklin_repo,
        version=franklin_version
    )
else
    Pkg.add(
        url=franklin_repo,
        rev=franklin_branch
    )
end
using Xranklin
build(
    site_folder;
    prefix=joinpath(base_url_prefix, preview),
    cleanup=false
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
        run(`$(npm) install cheerio --quiet`)
        run(`$(npm) install lunr --quiet`)
        bk = pwd()
        isempty(site_folder) || cd(site_folder)
        try
            run(`$(node()) $lunr_builder`)
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
println("---------------------------------------")
println("🏁🏁🏁 Franklin build process done 🏁🏁🏁")
println("---------------------------------------")
