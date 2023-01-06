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

def remove_open_source_files():
    file_names = ["CONTRIBUTORS.txt", "LICENSE"]
    for file_name in file_names:
        Path(file_name).unlink(missing_ok=True)

def remove_test_folder():
    shutil.rmtree("test")


def remove_constexpr_tests():
    Path("test/constexpr_tests.cpp").unlink(missing_ok=False)


def configure():
    print("=" * 120)
    print(f"Configuring cmake in build dir {BUILD_DIR}")
    cmd = ["cmake", "-S", ".", "-B", str(BUILD_DIR),
           "-DCMAKE_BUILD_TYPE:STRING={{ cookiecutter.build_type }}"]
    if "{{ cookiecutter.use_ninja }}".lower() != "n":
        cmd += ["-G" , "Ninja"]
    print("command =" + " ".join(cmd))
    env = os.environ
    if "{{ cookiecutter.compiler }}" == "GCC":
        env["CC"] = "gcc"
        env["CXX"] = "g++"
    elif "{{ cookiecutter.compiler }}" == "Clang":
        env["CC"] = "clang"
        env["CXX"] = "clang++"
    elif "{{ cookiecutter.compiler }}" == "Clang-15":
        env["CC"] = "clang-15"
        env["CXX"] = "clang++-15"
    subprocess.check_call(cmd, stderr=sys.stderr, stdout=sys.stdout, env=env)


def build():
    print("=" * 120)
    print("Building")
    try:
        subprocess.check_call(["cmake", "--build", str(BUILD_DIR)], stderr=sys.stderr, stdout=sys.stdout)
    except Exception as e:
        print(f"Failed to build: {e}")


def main():
    if "{{ cookiecutter.open_source_license }}" == "Not open source":
        remove_open_source_files()

    if "{{ cookiecutter.test_engine }}" == "None":
        remove_test_folder()
    elif "{{ cookiecutter.include_constexpr_tests }}".lower() != "y":
        remove_constexpr_tests()

    if "{{ cookiecutter.auto_build }}".lower() != "y":
        configure()
        build()


if __name__ == "__main__":
    main()
