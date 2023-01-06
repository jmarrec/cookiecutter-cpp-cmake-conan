# [Choice] bionic (18.04), focal (20.04), jammy (22.04)
ARG VARIANT="focal"
FROM ubuntu:${VARIANT}

# Restate the variant to use it later on in the llvm and cmake installations
ARG VARIANT

# Install necessary packages available from standard repos
RUN apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
    software-properties-common wget curl apt-utils file zip \
    openssh-client gpg-agent socat rsync \
    make ninja-build git \
    python3 python3-pip

# By default, anything you run in Docker is done as superuser.
# Conan runs some install commands as superuser, and will prepend `sudo` to
# these commands, unless `CONAN_SYSREQUIRES_SUDO=0` is in your env variables.
ENV CONAN_SYSREQUIRES_SUDO 0
# Some packages request that Conan use the system package manager to install
# a few dependencies. This flag allows Conan to proceed with these installations;
# leaving this flag undefined can cause some installation failures.
ENV CONAN_SYSREQUIRES_MODE enabled

# User-settable versions:
# This Dockerfile should support gcc-[7, 8, 9, 10, 11] and clang-[10, 11, 12, 13, 14, 15]
# Earlier versions of clang will require significant modifications to the IWYU section
ARG GCC_VER="11"
# Add gcc-${GCC_VER}
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        gcc-${GCC_VER} g++-${GCC_VER} gdb

# Set gcc-${GCC_VER} as default gcc
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} 100 \
                        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} \
                        --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VER} \
                        --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-${GCC_VER}

ARG LLVM_VER="15"
# Add clang-${LLVM_VER}
ARG LLVM_URL="http://apt.llvm.org/${VARIANT}/"
ARG LLVM_PKG="llvm-toolchain-${VARIANT}-${LLVM_VER}"
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - 2>/dev/null && \
    add-apt-repository -y "deb ${LLVM_URL} ${LLVM_PKG} main" && \
    apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        clang-${LLVM_VER} lldb-${LLVM_VER} lld-${LLVM_VER} clangd-${LLVM_VER} \
        llvm-${LLVM_VER}-dev libclang-${LLVM_VER}-dev clang-tidy-${LLVM_VER} \
        python3-clang-${LLVM_VER}

# Set clang-${LLVM_VER} as default clang, and clang-tidy too
# Set-up LLVM's linker as the default one, but allow easy switching
RUN update-alternatives --install /usr/bin/clang clang $(which clang-${LLVM_VER}) 100 \
                        --slave /usr/bin/clang++ clang++ $(which clang++-${LLVM_VER}) \
                        --slave /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VER}) \
                        --slave /usr/bin/lldb lldb $(which lldb-${LLVM_VER}) &&\
    update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 10 &&\
    update-alternatives --install /usr/bin/ld ld /usr/bin/ld.gold 20 &&\
    update-alternatives --install /usr/bin/ld ld /usr/bin/ld.lld-${LLVM_VER} 100

# Allow the user to set compiler defaults
ARG USE_CLANG
# if --build-arg USE_CLANG=1, set CC to 'clang' or set to null otherwise.
ENV CC=${USE_CLANG:+"clang"}
ENV CXX=${USE_CLANG:+"clang++"}
# if CC is null, set it to 'gcc' (or leave as is otherwise).
ENV CC=${CC:-"gcc"}
ENV CXX=${CXX:-"g++"}

# Add current cmake/ccmake, from Kitware
ARG CMAKE_URL="https://apt.kitware.com/ubuntu/"
ARG CMAKE_PKG=${VARIANT}
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
        | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository -y "deb ${CMAKE_URL} ${CMAKE_PKG} main" && \
    apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends cmake cmake-curses-gui

# Install editors
RUN apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        vim-gtk3 neovim emacs nano

# Install optional dependencies
ENV CPPCHECK_VERSION 2.9
RUN apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
    doxygen graphviz ccache \
    python3-dev \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    jq patchelf fzf &&\
    mkdir cppcheck && cd cppcheck &&\
    wget https://github.com/danmar/cppcheck/archive/${CPPCHECK_VERSION}.tar.gz &&\
    tar xfz ${CPPCHECK_VERSION}.tar.gz &&\
    mkdir build &&\
    cd build &&\
    cmake -DCMAKE_BUILD_TYPE=Release ../cppcheck-$CPPCHECK_VERSION/ &&\
    make -j $(nproc) &&\
    make install

# Install Rust for some CLI tools
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y --no-modify-path &&\
    ~/.cargo/bin/cargo install bat fd-find ripgrep exa

# Install include-what-you-use
ENV IWYU /home/iwyu
ENV IWYU_BUILD ${IWYU}/build
ENV IWYU_SRC ${IWYU}/include-what-you-use
RUN mkdir -p ${IWYU_BUILD} && \
    git clone --branch clang_${LLVM_VER} \
        https://github.com/include-what-you-use/include-what-you-use.git \
        ${IWYU_SRC}
RUN CC=clang-${LLVM_VER} CXX=clang++-${LLVM_VER} cmake -S ${IWYU_SRC} \
        -B ${IWYU_BUILD} \
        -G "Unix Makefiles" -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VER} && \
    cmake --build ${IWYU_BUILD} -j && \
    cmake --install ${IWYU_BUILD}

# Per https://github.com/include-what-you-use/include-what-you-use#how-to-install:
# `You need to copy the Clang include directory to the expected location before
#  running (similarly, use include-what-you-use -print-resource-dir to learn
#  exactly where IWYU wants the headers).`
RUN mkdir -p $(include-what-you-use -print-resource-dir 2>/dev/null)
RUN ln -s $(readlink -f /usr/lib/clang/${LLVM_VER}/include) \
    $(include-what-you-use -print-resource-dir 2>/dev/null)/include

# Install conan
RUN python3 -m pip install --upgrade pip setuptools && \
    python3 -m pip install conan ipython twine requests packaging thefuck gcovr && \
    conan --version &&\
    conan profile new --detect default &&\
    conan profile update settings.compiler.libcxx=libstdc++11 default &&\
    conan config set general.revisions_enabled=True && conan config set general.parallel_download=8

## Cleanup cached apt data we don't need anymore
RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Include project
#ADD . /workspaces/cpp_starter_project
#WORKDIR /workspaces/cpp_starter_project

# Add some config files
COPY .inputrc .vimrc .bashrc ./root/
COPY git-prompt.sh ~/.config/git/
# Preinstall the vim-plug stuff
RUN vim +'PlugInstall --sync' +qa

CMD ["/bin/bash"]
