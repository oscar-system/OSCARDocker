FROM ubuntu:xenial

MAINTAINER Sebastian Gutsche <sebastian.gutsche@gmail.com>

RUN    apt-get update -qq \
    && apt-get install -y \
       4ti2 \
       ant \
       ant-optional \
       autoconf \
       autogen \
       bliss \
       build-essential \
       bzip2 \
       clang \
       cmake \
       curl \
       debhelper \
       default-jdk \
       gfortran \
       git \
       graphviz \
       language-pack-el-base \
       language-pack-en \
       libbliss-dev \
       libboost-dev \
       libboost-python-dev \
       libcdd-dev \
       libcdd0d \
       libdatetime-perl \
       libflint-dev \
       libglpk-dev \
       libgmp-dev \
       libgmp10 \
       libgmpxx4ldbl \
       libjson-perl \
       libmpfr-dev \
       libncurses5-dev \
       libnormaliz-dev \
       libntl-dev \
       libperl-dev \
       libppl-dev \
       libreadline6-dev \
       libsvn-perl \
       libterm-readkey-perl \
       libterm-readline-gnu-perl \
       libtool \
       libxml-libxml-perl \
       libxml-libxslt-perl \
       libxml-perl \
       libxml-writer-perl \
       libxml2-dev \
       libxslt-dev \
       libzmq3-dev \
       m4 \
       make \
       nano \
       ninja-build \
       patch \
       pkg-config \
       python-dev \
       python3-pip \
       sudo \
       unzip \
       vim \
       wget \
       xsltproc

RUN    adduser --quiet --shell /bin/bash --gecos "OSCAR user,101,," --disabled-password oscar \
    && adduser oscar sudo \
    && chown -R oscar:oscar /home/oscar/ \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && cd /home/oscar \
    && touch .sudo_as_admin_successful

USER oscar

ENV HOME /home/oscar
WORKDIR /home/oscar

COPY Make.user /home/oscar/Make.user

ENV MARCH x86-64

RUN    wget https://github.com/JuliaLang/julia/releases/download/v1.0.2/julia-1.0.2-full.tar.gz \
    && tar xf julia-1.0.2-full.tar.gz \
    && rm  julia-1.0.2-full.tar.gz \
    && cd julia \
    && export MARCH=x86-64 \
    && cp ../Make.user . \
    && make \
    && sudo ln -snf /home/oscar/julia/julia /usr/local/bin/julia

RUN    wget https://polymake.org/lib/exe/fetch.php/download/polymake-3.2r2.tar.bz2 \
    && tar xf polymake-3.2r2.tar.bz2 \
    && rm polymake-3.2r2.tar.bz2 \
    && cd polymake-3.2 \
    && ./configure --without-native \
    && sudo ninja -C build/Opt install


ENV CURRENT_DATE_DOCKER=unkonwn
RUN   CURRENT_DATE_DOCKER=${CURRENT_DATE_DOCKER} cd /home/oscar/ \
    && wget -q https://github.com/gap-system/gap/archive/master.zip \
    && unzip -q master.zip \
    && rm master.zip \
    && cd gap-master \
    && ./autogen.sh \
    && ./configure \
    && make \
    && mkdir pkg \
    && cd pkg \
    && wget -q https://www.gap-system.org/pub/gap/gap4pkgs/packages-master.tar.gz \
    && tar xzf packages-master.tar.gz \
    && rm packages-master.tar.gz \
    && ../bin/BuildPackages.sh

RUN    sudo pip3 install notebook jupyterlab_launcher jupyterlab traitlets ipython vdom

RUN    cd /home/oscar/gap-master/pkg \
    && git clone https://github.com/gap-packages/JupyterKernel.git \
    && cd JupyterKernel \
    && python3 setup.py install --user \
    && cd .. \
    && git clone https://github.com/oscar-system/GAPJulia \
    && cd GAPJulia/JuliaInterface \
    && ./autogen.sh \
    && ./configure --with-gaproot=/home/oscar/gap-master --with-julia=/home/oscar/julia/usr \
    && make \
    && cd ../JuliaExperimental \
    && ./autogen.sh \
    && ./configure --with-gaproot=/home/oscar/gap-master --with-julia=/home/oscar/julia/usr --with-juliainterface=../JuliaInterface \
    && make \
    && sudo ln -snf /home/oscar/gap-master/gap /usr/local/bin/gap

COPY install_hecke.jl /home/oscar/install_hecke.jl
RUN CURRENT_DATE_DOCKER=${CURRENT_DATE_DOCKER} julia install_hecke.jl

ENV JULIA_CXX_RTTI 1

COPY install_cxx.jl /home/oscar/install_cxx.jl
RUN julia install_cxx.jl

COPY compile_cxx.jl /home/oscar/compile_cxx.jl
RUN julia < compile_cxx.jl

ENV POLYMAKE_CONFIG polymake-config

COPY install_polymake.jl /home/oscar/install_polymake.jl
RUN julia install_polymake.jl

COPY install_singular.jl /home/oscar/install_singular.jl
RUN sudo julia install_singular.jl

COPY install_oscar.jl /home/oscar/install_oscar.jl
RUN julia install_oscar.jl

COPY install_ijulia.jl /home/oscar/install_ijulia.jl
RUN julia install_ijulia.jl

RUN touch /home/oscar/.julia/v0.6/Cxx/src/Cxx.jl

RUN echo "c.NotebookApp.token = ''" > /home/oscar/.jupyter/jupyter_notebook_config.py

COPY Examples Examples

ENV PATH /home/oscar/gap-master/pkg/JupyterKernel/bin:${PATH}
ENV JUPYTER_GAP_EXECUTABLE /home/oscar/gap-master/bin/gap.sh
