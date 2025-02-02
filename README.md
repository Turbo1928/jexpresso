# JEXPRESSO
A research and educational software for the numerical solution of 1D, 2D, and 3D PDEs using spectral and spectral element methods on CPUs and GPUs. DISCLAIMER: this is WIP.

If you are interested in contributing, please get in touch.

# Some notes on using JEXPRESSO

To install and run the code assume Julia
version 1.7.2 or higher (tested up to 1.8.5)

## Setup with CPUs

```bash
>> cd $JEXPRESSO_HOME
>> julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.API.precompile()"
```
followed by the following:

Push problem name to ARGS
You need to do this only when you run a new problem
```bash
julia> push!(empty!(ARGS), PROBLEM_NAME::String);
julia> include(./src/run.jl)
```

PROBLEM_NAME is the name of your problem directory as $JEXPRESSO/src/problems/problem_name
Ex. If you run the Advection Diffusion problem in $JEXPRESSO/src/problems/AdvDiff
```bash
julia> push!(empty!(ARGS), "AdvDiff");
julia> include(./src/run.jl)
```

Currently available problem names:

* AdvDiff
* Elliptic

More are already implemented but currently only in individual branches. They will be added to master after proper testing.

## Plotting
For plotting we rely on `PlotlyJS`. If you want to use a different package,
modify ./src/io/plotting/jplots.jl accordinly.

## Contacts
[Simone Marras](mailto:smarras@njit.edu), [Yassine Tissaoui](mailto:yt277@njit.edu)

