import Pkg
Pkg.add("NodeJS_16_jll")

run(`$(npm) install cheerio`)
run(`$(npm) install lunr`)

println("Building the Lunr index")
run(`$(node()) $lunr_builder`)
