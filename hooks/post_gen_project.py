import os
import shutil
import subprocess
import sys
from pathlib import Path

BUILD_DIR = Path("../{{ cookiecutter.project_slug }}-build-{{ cookiecutter.build_type }}")

HAS_RICH = True
try:
    from rich import print
except ImportError:
    HAS_RICH = False


class CMakeConfigureError(Exception):
    """An exception class for the cmake configuration."""

    def __init__(self, *args, **kwargs):
        default_message = "CMake Configure Error"
        if args:
            super().__init__(*args, **kwargs)
        else:
            super().__init__(default_message, **kwargs)


class BuildError(Exception):
    """An exception class for the build."""

    def __init__(self):
        super().__init__("Build Error")


class CTestError(Exception):
    """An exception class for the CTest run."""

    def __init__(self):
        super().__init__("CTest Error")


def remove_open_source_files():
    """Remove the license and co."""
    file_names = ["CONTRIBUTORS.txt", "LICENSE"]
    for file_name in file_names:
        Path(file_name).unlink(missing_ok=True)


def remove_test_folder():
    """Remove the test folder when no engine is selected."""
    shutil.rmtree("test")


def remove_constexpr_tests():
    """Remove the constexpr tests."""
    Path("test/constexpr_tests.cpp").unlink(missing_ok=False)


def configure():
    """Configure the project via CMake."""
    print("=" * 120)
    print(f"Configuring cmake in build dir {BUILD_DIR}")
    cmd = ["cmake", "-S", ".", "-B", str(BUILD_DIR), "-DCMAKE_BUILD_TYPE:STRING={{ cookiecutter.build_type }}"]
    if "{{ cookiecutter.use_ninja }}".lower() != "n":
        cmd += ["-G", "Ninja"]
    print("command =" + " ".join(cmd))
    env = os.environ
    if "{{ cookiecutter.compiler }}" == "GCC":
        env["CC"] = "gcc"
        env["CXX"] = "g++"
    elif "{{ cookiecutter.compiler }}" == "Clang":
        env["CC"] = "clang"
        env["CXX"] = "clang++"
    try:
        subprocess.check_call(cmd, stderr=sys.stderr, stdout=sys.stdout, env=env)
    except subprocess.CalledProcessError as e:
        raise CMakeConfigureError(" ".join(cmd)) from e


def build(allow_failure: bool = False):
    """Build the project."""
    print("=" * 120)
    print("Building")
    try:
        subprocess.check_call(["cmake", "--build", str(BUILD_DIR)], stderr=sys.stderr, stdout=sys.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Failed to build: {e}")
        if not allow_failure:
            raise BuildError() from e
        return False

    return True


def ctest():
    """Run CTest"""
    try:
        subprocess.check_call(["ctest", "--test-dir", str(BUILD_DIR)], stderr=sys.stderr, stdout=sys.stdout)
    except subprocess.CalledProcessError as e:
        raise CTestError() from e


def main():
    if "{{ cookiecutter.open_source_license }}" == "Not open source":
        remove_open_source_files()

    if "{{ cookiecutter.test_engine }}" == "None":
        remove_test_folder()
    elif "{{ cookiecutter.test_engine }}" != "Catch2" or "{{ cookiecutter.include_constexpr_tests }}".lower() != "y":
        remove_constexpr_tests()

    if "{{ cookiecutter.auto_build }}".lower() == "y":
        configure()
        ok = build()
        if ok:
            ctest()


if __name__ == "__main__":
    main()
