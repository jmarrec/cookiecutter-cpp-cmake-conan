cmake_minimum_required(VERSION 3.15...3.23)

project(CmakeConfigPackageTests LANGUAGES CXX)

# ---- Test as standalone project the exported config package ----

if(PROJECT_IS_TOP_LEVEL OR TEST_INSTALLED_VERSION)
  enable_testing()

  find_package({{ cookiecutter.project_slug }} CONFIG REQUIRED) # for intro, project_options, ...

  if(NOT TARGET {{ cookiecutter.project_slug }}::project_options)
    message(FATAL_ERROR "Required config package not found!")
    return() # be strictly paranoid for Template Janitor github action! CK
  endif()
endif()

{%- if cookiecutter.make_cli.lower() == "y" %}
#######################################################################
#                       C L I    T E S T I N G                        #
#######################################################################

# Provide a simple smoke test to make sure that the CLI works and can display a --help message
add_test(NAME cli.has_help COMMAND intro --help)

# Provide a test to verify that the version being reported from the application
# matches the version given to CMake. This will be important once you package
# your program. Real world shows that this is the kind of simple mistake that is easy
# to make, but also easy to test for.
add_test(NAME cli.version_matches COMMAND intro --version)
set_tests_properties(cli.version_matches PROPERTIES PASS_REGULAR_EXPRESSION "${PROJECT_VERSION}")
{%- endif %}

{%- if cookiecutter.test_engine == "Catch2" %}

# ---- Dependencies ----
find_package(Catch2 CONFIG REQUIRED)

include(Catch)
add_executable(tests tests.cpp)
target_link_libraries(tests PRIVATE {{ cookiecutter.project_slug }}::project_warnings {{ cookiecutter.project_slug }}::project_options Catch2::Catch2WithMain)

# automatically discover tests that are defined in catch based test files you can modify the unittests. Set TEST_PREFIX
# to whatever you want, or use different for different binaries
catch_discover_tests(
  tests
  TEST_PREFIX
    "unittests."
  REPORTER
    XML
  OUTPUT_DIR
    .
  OUTPUT_PREFIX
    "unittests."
  OUTPUT_SUFFIX
    .xml
)
  {% if cookiecutter.include_constexpr_tests.lower() == 'y' %}
#######################################################################
#                 C O N S T E X P R    T E S T I N G                  #
#######################################################################

# Add a file containing a set of constexpr tests
add_executable(constexpr_tests constexpr_tests.cpp)
target_link_libraries(constexpr_tests PRIVATE {{ cookiecutter.project_slug }}::project_options {{ cookiecutter.project_slug }}::project_warnings Catch2::Catch2WithMain)

catch_discover_tests(
  constexpr_tests
  TEST_PREFIX
    "constexpr."
  REPORTER
    XML
  OUTPUT_DIR
    .
  OUTPUT_PREFIX
    "constexpr."
  OUTPUT_SUFFIX
    .xml
)

# Disable the constexpr portion of the test, and build again this allows us to have an executable that we can debug when
# things go wrong with the constexpr testing
add_executable(relaxed_constexpr_tests constexpr_tests.cpp)
target_link_libraries(relaxed_constexpr_tests PRIVATE {{ cookiecutter.project_slug }}::project_options {{ cookiecutter.project_slug }}::project_warnings Catch2::Catch2WithMain)
target_compile_definitions(relaxed_constexpr_tests PRIVATE -DCATCH_CONFIG_RUNTIME_STATIC_REQUIRE)

catch_discover_tests(
  relaxed_constexpr_tests
  TEST_PREFIX
    "relaxed_constexpr."
  REPORTER
    XML
  OUTPUT_DIR
    .
  OUTPUT_PREFIX
    "relaxed_constexpr."
  OUTPUT_SUFFIX
    .xml
)
  {%- endif -%} {# End of Catch2 constexpr tests #}
{%- elif cookiecutter.test_engine == "gtest" %}

# ---- Dependencies ----
find_package(GTest CONFIG REQUIRED)

add_executable(tests tests.cpp)
target_link_libraries(tests PRIVATE {{ cookiecutter.project_slug }}::project_warnings {{ cookiecutter.project_slug }}::project_options GTest::GTest)

include(GoogleTest)
gtest_discover_tests(tests
  # WORKING_DIRECTORY Testing
)
{%- endif %}{# End of Catch2/gtest #}
