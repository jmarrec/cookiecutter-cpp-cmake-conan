"""Py.test module for the cookiecutter cpp-conan-cmake.

This makes use of pytest-cookies.
"""
import os
import re
from pathlib import Path

import pytest
from binaryornot.check import is_binary

PATTERN = r"{{(\s?cookiecutter)[.](.*?)}}"
RE_OBJ = re.compile(PATTERN)


@pytest.fixture
def context():
    """Py.test fixture that provides some default context."""
    return {
        "project_name": "Test cookiecutter-cpp-cmake-conan",
        "project_slug": "test_cookiecutter_cpp_cmake_conan",
        "description": "A test for https://github.com/jmarrec/cookiecutter-cpp-cmake-conan",
        "author_name": "Julien Marrec",
        "github_organization": "jmarrec",
        "github_repo": "Test-cookiecutter-cpp-cmake-conan",
        "auto_build": "n",
    }


# SUPPORTED_COMBINATIONS = supported_combinations.get_supported_combinations(supported_combinations.COOKIECUTTER_FILE)
SUPPORTED_COMBINATIONS = [
    {"make_cli": "y"},
    {"make_cli": "n"},
    {"test_engine": "gtest"},
    {"test_engine": "Catch2"},
    {"test_engine": "None"},
    {"open_source_license": "MIT"},
    {"open_source_license": "BSD"},
    {"open_source_license": "GPLv3"},
    {"open_source_license": "Apache Software License 2.0"},
    {"open_source_license": "Not open source"},
    # {'auto_build': 'y'},
    # {'auto_build': 'n'},
    {"build_type": "Debug"},
    {"build_type": "Release"},
    {"build_type": "RelWithDebInfo"},
    {"compiler": "default"},
    {"compiler": "GCC"},
    {"compiler": "Clang"},
    {"use_ninja": "y"},
    {"use_ninja": "n"},
]


def _fixture_id(ctx):
    """Helper to get a user-friendly test name from the parametrized context."""
    return "-".join(f"{key}:{value}" for key, value in ctx.items())


def build_files_list(root_dir):
    """Build a list containing absolute paths to the generated files."""
    return [os.path.join(dirpath, file_path) for dirpath, subdirs, files in os.walk(root_dir) for file_path in files]


def check_paths(paths):
    """Method to check all paths have correct substitutions."""
    # Assert that no match is found in any of the files
    for path in paths:
        if is_binary(path):
            continue

        for line in open(path):
            match = RE_OBJ.search(line)
            assert match is None, f"cookiecutter variable not replaced in {path}"


@pytest.mark.parametrize("context_override", SUPPORTED_COMBINATIONS, ids=_fixture_id)
def test_project_generation(cookies, context, context_override):
    """Test that project is generated and fully rendered."""
    result = cookies.bake(extra_context={**context, **context_override})
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project_path.name == context["project_slug"]
    assert result.project_path.is_dir()

    paths = build_files_list(str(result.project_path))
    assert paths
    check_paths(paths)


def test_test_engine_gtest(cookies, context):
    """Tests that when Gtest is selected the constexpr tests are removed."""
    result = cookies.bake(extra_context={**context, **{"test_engine": "gtest", "include_constexpr_tests": "y"}})
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project_path.name == context["project_slug"]
    assert result.project_path.is_dir()
    assert isinstance(result.project_path, Path)
    assert (result.project_path / "test").is_dir()
    assert not (result.project_path / "test" / "constexpr_tests.cpp").is_file()


def test_test_engine_Catch2_no_constexpr(cookies, context):
    """Test when Catch2 and we say no to constexpr tests, they are removed."""
    result = cookies.bake(extra_context={**context, **{"test_engine": "Catch2", "include_constexpr_tests": "n"}})
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project_path.name == context["project_slug"]
    assert result.project_path.is_dir()
    assert isinstance(result.project_path, Path)
    assert (result.project_path / "test").is_dir()
    assert not (result.project_path / "test" / "constexpr_tests.cpp").is_file()


def test_test_engine_Catch2_constexpr(cookies, context):
    """Test when Catch2 and we say yes to constexpr tests, they are not removed."""
    result = cookies.bake(extra_context={**context, **{"test_engine": "Catch2", "include_constexpr_tests": "y"}})
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project_path.name == context["project_slug"]
    assert result.project_path.is_dir()
    assert isinstance(result.project_path, Path)
    assert (result.project_path / "test").is_dir()
    assert (result.project_path / "test" / "constexpr_tests.cpp").is_file()


AUTO_BUILD_CONFIGURATIONS = [
    {"build_type": "Release", "compiler": "default", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "default", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "default", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "GCC", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "GCC", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "GCC", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "Clang", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "Clang", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "Release", "compiler": "Clang", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "default", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "default", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "GCC", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "GCC", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "GCC", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "Clang", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "Clang", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "Debug", "compiler": "Clang", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "default", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "default", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "default", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "GCC", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "GCC", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "GCC", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "Clang", "make_cli": "n", "test_engine": "gtest", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "Clang", "make_cli": "n", "test_engine": "Catch2", "use_ninja": "y"},
    {"build_type": "RelWithDebInfo", "compiler": "Clang", "make_cli": "n", "test_engine": "None", "use_ninja": "y"},
]

if os.getenv("CI"):
    AUTO_BUILD_CONFIGURATIONS = AUTO_BUILD_CONFIGURATIONS[:1]


@pytest.mark.parametrize("context_override", AUTO_BUILD_CONFIGURATIONS, ids=_fixture_id)
def test_auto_build(cookies, context, context_override):
    """Test that project is generated and fully rendered."""
    result = cookies.bake(extra_context={**context, **{"auto_build": "y"}, **context_override})
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project_path.name == context["project_slug"]
    build_type = context_override["build_type"]
    build_dir = result.project_path.parent / f"{result.project_path.name}-build-{build_type}"
    assert build_dir.is_dir()
    # Run ctest?
