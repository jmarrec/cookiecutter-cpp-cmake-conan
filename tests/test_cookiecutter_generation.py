import os
import re
import sys

import pytest

#import yaml
from binaryornot.check import is_binary
#from cookiecutter.exceptions import FailedHookException


PATTERN = r"{{(\s?cookiecutter)[.](.*?)}}"
RE_OBJ = re.compile(PATTERN)

if sys.platform.startswith("win"):
    pytest.skip("sh doesn't support windows", allow_module_level=True)
elif sys.platform.startswith("darwin") and os.getenv("CI"):
    pytest.skip("skipping slow macOS tests on CI", allow_module_level=True)


@pytest.fixture
def context():
    return {
        "project_name": "Test cookiecutter-cpp-cmake-conan",
        "project_slug": "test_cookiecutter_cpp_cmake_conan",
        "description": "A test for https://github.com/jmarrec/cookiecutter-cpp-cmake-conan",
        "make_cli": "n",
        "test_engine": "gtest",
        "include_constexpr_tests": "y",
        "author_name": "Julien Marrec",
        "github_organization": "jmarrec",
        "github_repo": "Test-cookiecutter-cpp-cmake-conan",
        "open_source_license": "MIT",
        "auto_build": "n",
        "build_type": "Debug",
        "compiler": "default",
        "use_ninja": "y"
    }

# SUPPORTED_COMBINATIONS = supported_combinations.get_supported_combinations(supported_combinations.COOKIECUTTER_FILE)
SUPPORTED_COMBINATIONS = [
    {'make_cli': 'y'},
    {'make_cli': 'n'},
    {'test_engine': 'gtest'},
    {'test_engine': 'Catch2'},
    {'test_engine': 'None'},
    {'open_source_license': 'MIT'},
    {'open_source_license': 'BSD'},
    {'open_source_license': 'GPLv3'},
    {'open_source_license': 'Apache Software License 2.0'},
    {'open_source_license': 'Not open source'},
    # {'auto_build': 'y'},
    # {'auto_build': 'n'},
    {'build_type': 'Debug'},
    {'build_type': 'Release'},
    {'build_type': 'RelWithDebInfo'},
    {'compiler': 'default'},
    {'compiler': 'GCC'},
    {'compiler': 'Clang'},
    {'use_ninja': 'y'},
    {'use_ninja': 'n'},
]

SUPPORTED_COMBINATIONS = [
    {"test_engine": "Catch2"},
    {"test_engine": "gtest"},
    {"test_engine": "None"},
]


def _fixture_id(ctx):
    """Helper to get a user-friendly test name from the parametrized context."""
    return "-".join(f"{key}:{value}" for key, value in ctx.items())


def build_files_list(root_dir):
    """Build a list containing absolute paths to the generated files."""
    return [
        os.path.join(dirpath, file_path)
        for dirpath, subdirs, files in os.walk(root_dir)
        for file_path in files
    ]


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
