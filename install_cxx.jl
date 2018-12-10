using Pkg
Pkg.update()
Pkg.clone( "https://github.com/Keno/Cxx.jl" )
Pkg.build( "Cxx" )
