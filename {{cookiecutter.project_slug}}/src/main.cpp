{% if cookiecutter.make_cli.lower() == "y" -%}
#include <functional>
#include <optional>

#include <CLI/CLI.hpp>
{% endif -%}
#include <fmt/format.h>

// This file will be generated automatically when you run the CMake configuration step.
// It creates a namespace called `{{ cookiecutter.project_slug }}`.
// You can modify the source template at `configured_files/config.hpp.in`.
#include <internal_use_only/config.hpp>

// NOLINTNEXTLINE(bugprone-exception-escape)
{%- if cookiecutter.make_cli.lower() == "y" %}
int main(int argc, const char **argv) {
  try {
    CLI::App app{ fmt::format("{} version {}", {{ cookiecutter.project_slug }}::cmake::project_name, {{ cookiecutter.project_slug }}::cmake::project_version) };

    std::optional<std::string> message;
    app.add_option("-m,--message", message, "A message to print back out");
    bool show_version = false;
    app.add_flag("--version", show_version, "Show version information");

    CLI11_PARSE(app, argc, argv);

    if (show_version) {
      fmt::print("{}\n", {{ cookiecutter.project_slug }}::cmake::project_version);
      return EXIT_SUCCESS;
    }

    fmt::print("Hello, {}!", "World");

    if (message) {
      fmt::print("Message: '{}'\n", *message);
    } else {
      fmt::print("No Message Provided :(\n");
    }
  } catch (const std::exception &e) {
    fmt::print("Unhandled exception in main: {}", e.what());
  }
{%- else %}
int main([[maybe_unused]] int argc, [[maybe_unused]] const char **argv) {
  fmt::print("{} version {}", {{ cookiecutter.project_slug }}::cmake::project_name, {{ cookiecutter.project_slug }}::cmake::project_version);
{%- endif %}
}
