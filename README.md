# Cookiecutter C++ CMake Conan

A cookiecutter C++ with modern CMake and conan template, for easy deployment locally.

Setup with a .devcontainer, Github Actions, etc.

Loosely adapted from [cpp-best-practices/cmake_conan_boilerplate_template](https://github.com/cpp-best-practices/cmake_conan_boilerplate_template) and makes use of [aminya/project_options](https://github.com/aminya/project_options) for modern CMake.

## Usage

First, get Cookiecutter.

```shell
$ pip install "cookiecutter>=1.7.0"
```

Place yourself in the directory where you want your new project to reside.

Now run it against this repo::

```shell
$ cookiecutter https://github.com/jmarrec/cookiecutter-cpp-cmake-conan
```

It will ask for a few questions. The project_slug is going to become your new folder in which the new project files reside.

![cookiecutter-cpp-cmake-conan-demo](https://user-images.githubusercontent.com/5479063/211117435-b7e2cae6-c877-4a97-a94b-4aeb1a0c5c8c.gif)

### Options

* `test_engine`: `Catch2`, `gtest` or `None`.
    * If Catch2, option to include `constexpr` tests or not
* `make_cli` CLI: if true, makes a simple CLI with CLI11 and spdlog, otherwise, just a dumb fmt::print statement in main.cpp
* `auto_build` is `y`, it will automatically create a build folder, call CMake configure, and build. Subsequent options are only valid if `y`
    * `compiler`: `default`, or `gcc` or `clang` in which case it passes `CC=gcc CXX=g++` and ``CC=clang CXX=clang++`` respectively
    * `build_type`: passed as `-DCMAKE_BUILD_TYPE:STRING=XXX`
    * `use_ninja`: if `y` it will append `-G Ninja` to the configure script

### Features

I have configured [Dockerfile](%7B%7Bcookiecutter.project_slug%7D%7D/.devcontainer/Dockerfile) for my taste (with a subset of my dotfiles) so I have a familiar environment to use.
Some images are posted on my Dockerhub, eg [jmarrec/cookiecutter-cpp-cmake-conan-gcc11-clang15](https://hub.docker.com/repository/docker/jmarrec/cookiecutter-cpp-cmake-conan-gcc11-clang15/general)

# TODO / Roadmap

* I think there are too many dependencies on small external scripts and actions for my taste, things are likely to break.
    * At least for the Github Actions ci.yml, I'd like to remove the dependency on setup-cpp action
        * It's failing
        * It's opaque
        * It currently tries to build too many configurations
* Add (an option to use?) a library (`add_library`) and use that in tests and fuzzing tests.
