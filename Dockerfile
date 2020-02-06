FROM ubuntu:xenial

MAINTAINER The OSCAR team <oscar-dev@mathematik.uni-kl.de>

RUN    apt-get update -qq \
    && apt-get install -y \
       autoconf \
       build-essential \
       bzip2 \
       cmake \
       curl \
       debhelper \
       git \
       libcurl4-gnutls-dev \
       libczmq-dev \
       libgmp-dev \
       libreadline6-dev \
       libtool \
       m4 \
       make \
       python3-dev \
       python3-pip \
       sudo \
       wget \
       zlib1g-dev

RUN    adduser --quiet --shell /bin/bash --gecos "OSCAR user,101,," --disabled-password oscar \
    && adduser oscar sudo \
    && chown -R oscar:oscar /home/oscar/ \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && cd /home/oscar \
    && touch .sudo_as_admin_successful

USER oscar

ENV HOME /home/oscar
WORKDIR /home/oscar

RUN sudo pip3 install notebook jupyterlab_launcher jupyterlab traitlets ipython vdom
RUN    mkdir .jupyter \
    && echo "c.NotebookApp.token = ''" > /home/oscar/.jupyter/jupyter_notebook_config.py

### Install Julia

ENV JULIA_VERSION julia-1.3.1

RUN    wget https://julialang-s3.julialang.org/bin/linux/x64/1.3/${JULIA_VERSION}-linux-x86_64.tar.gz \
    && tar xf ${JULIA_VERSION}-linux-x86_64.tar.gz \
    && rm ${JULIA_VERSION}-linux-x86_64.tar.gz \ 
    && sudo ln -snf /home/oscar/${JULIA_VERSION}/bin/julia /usr/local/bin/julia

### Install Julia packages

RUN julia -e 'import Pkg; Pkg.add( "IJulia" )'
RUN julia -e 'import Pkg; Pkg.add( "AbstractAlgebra" )'
RUN julia -e 'import Pkg; Pkg.add( "Nemo" )'
RUN julia -e 'import Pkg; Pkg.add( "Polymake" )'
RUN julia -e 'import Pkg; Pkg.add( "Singular" )'
RUN julia -e 'import Pkg; Pkg.add( "GAP" )'
RUN julia -e 'import Pkg; Pkg.add( "Hecke" )'
RUN julia -e 'import Pkg; Pkg.add(Pkg.PackageSpec(url="https://github.com/oscar-system/OSCAR.jl", rev="master"))'

COPY Examples Examples

# TODO/FIXME: setup GAP package JupyterKernel

RUN ln -s $(julia -e 'print(abspath(joinpath(dirname(Base.find_package("GAP")), "..", "gap")))') /home/oscar/gap

RUN    cd /home/oscar/gap/pkg \
    && git clone https://github.com/gap-packages/JupyterKernel.git \
    && cd JupyterKernel \
    && python3 setup.py install --user

ENV PATH /home/oscar/gap/pkg/JupyterKernel/bin:${PATH}
ENV JUPYTER_GAP_EXECUTABLE /home/oscar/.julia/gap.sh
ENV GAPROOT /home/oscar/gap
