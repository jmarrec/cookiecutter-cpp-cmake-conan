# {{cookiecutter.github_repo}}

[![ci](https://github.com/{{cookiecutter.github_organization}}/{{cookiecutter.github_repo}}/actions/workflows/ci.yml/badge.svg)](https://github.com/{{cookiecutter.github_organization}}/{{cookiecutter.github_repo}}/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/{{cookiecutter.github_organization}}/{{cookiecutter.github_repo}}/branch/main/graph/badge.svg)](https://codecov.io/gh/{{cookiecutter.github_organization}}/{{cookiecutter.github_repo}})
[![CodeQL](https://github.com/{{cookiecutter.github_organization}}/{{cookiecutter.github_repo}}/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/{{cookiecutter.github_organization}}/{{cookiecutter.github_repo}}/actions/workflows/codeql-analysis.yml)

{{cookiecutter.description}}

## More Details

 * [Dependency Setup](README_dependencies.md)
 * [Building Details](README_building.md)
 * [Troubleshooting](README_troubleshooting.md)
 * [Docker](README_docker.md)
{%- if cookiecutter.test_engine != "None" %}

## Testing
  {%- if cookiecutter.test_engine == "Catch2" %}

See [Catch2 tutorial](https://github.com/catchorg/Catch2/blob/master/docs/tutorial.md)
  {%- elif cookiecutter.test_engine == "gtest" %}

See [Google Test User Guide](https://google.github.io/googletest/)
  {%- endif %}
{%- endif %}

## Fuzz testing

See [libFuzzer Tutorial](https://github.com/google/fuzzing/blob/master/tutorial/libFuzzerTutorial.md)
