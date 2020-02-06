# OSCAR Docker Repository

This Docker file contains a recent version of the software in the OSCAR project:

- Julia
- Polymake
- Singular

and the Julia modules

- Singular.jl
- Polymake.jl
- Nemo.jl
- Hecke.jl
- Oscar.jl

Furthermore Jupyter and the Julia Kernel for Jupyter is installed.

## Usage

To start Julia in the Docker image, execute

    docker run -it oscarsystem/oscardocker:latest

You can then start julia via the command

    julia

and load Singular.jl via

    using Singular

or Polymake.jl via

    using Polymake

For an examples see [here](https://nbviewer.jupyter.org/github/oscar-system/OSCARBinder/blob/master/Singular.ipynb) for Singular and [here](https://nbviewer.jupyter.org/github/oscar-system/OSCARBinder/blob/master/g-vectors_of_random_simplicial_6-polytopes.ipynb)
for Polymake.

## Usage of Jupyter

To start a Jupyter Notebook server, execute the image with

    docker run -it --net="host" oscarsystem/oscardocker:latest

and after the container started, execute

    jupyter notebook --no-browser

inside the container. Then open the URL displayed in your terminal.

## Usage on [mybinder.org](http://mybinder.org)

You can use this Docker image as base for your Binder docker repository. See [here](https://github.com/oscar-system/OSCARBinder) for an example. Please note that the versions are tagged by date.