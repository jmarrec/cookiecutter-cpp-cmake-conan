import itertools
import json
from pathlib import Path

TEST_DIR = Path(__file__).resolve().parent
COOKIECUTTER_FILE = (TEST_DIR / "../cookiecutter.json").resolve()


def get_supported_combinations(cookiecutter_file: Path) -> [dict]:
    with open(cookiecutter_file, "r") as f:
        data = json.load(f)
    result = []
    for k, v in data.items():
        if k.startswith("_"):
            continue
        if isinstance(v, str) and v in ["y", "n"]:
            result.append({k: "y"})
            result.append({k: "n"})

        elif isinstance(v, list):
            for x in v:
                result.append({k: x})
    return result


def get_build_combinations(cookiecutter_file: Path):

    BUILD_OPTIONS = [
        "build_type",
        "compiler",
        "make_cli",
        "test_engine",
        "use_ninja",
    ]
    with open(cookiecutter_file, "r") as f:
        data = json.load(f)
    build_opts = {k: data[k] for k in BUILD_OPTIONS}

    allNames = sorted(build_opts)
    combinations = itertools.product(*(build_opts[Name] for Name in allNames))
    result = [dict(zip(allNames, c)) for c in combinations]


if __name__ == "__main__":
    SUPPORTED_COMBINATIONS = get_supported_combinations(COOKIECUTTER_FILE)
    print(COOKIECUTTER_FILE)
    print(SUPPORTED_COMBINATIONS)
