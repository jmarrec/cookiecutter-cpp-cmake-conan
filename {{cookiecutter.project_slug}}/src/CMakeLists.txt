find_package(fmt CONFIG REQUIRED)
{%- if cookiecutter.make_cli.lower() == "y" %}
find_package(CLI11 CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
{%- endif %}

# Generic test that uses conan libs
add_executable(intro main.cpp)
target_link_libraries(
  intro
  PUBLIC project_options project_warnings
  PRIVATE
    fmt::fmt
  {%- if cookiecutter.make_cli.lower() == "y" %}
    CLI11::CLI11
    spdlog::spdlog
  {%- endif %}
)

target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
