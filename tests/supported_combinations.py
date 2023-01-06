from pathlib import Path
import json

TEST_DIR = Path(__file__).resolve().parent
COOKIECUTTER_FILE = (TEST_DIR / "../cookiecutter.json").resolve()

def get_supported_combinations(cookiecutter_file: Path) -> [dict]:
    with open(cookiecutter_file, 'r') as f:
        data = json.load(f)
    result = []
    for k, v in data.items():
        if k.startswith('_'):
            continue
        if isinstance(v, str) and v in ['y', 'n']:
            result.append({k: 'y'})
            result.append({k: 'n'})

        elif isinstance(v, list):
            for x in v:
                result.append({k: x})
    return result

if __name__ == "__main__":
    SUPPORTED_COMBINATIONS = get_supported_combinations(COOKIECUTTER_FILE)
    print(COOKIECUTTER_FILE)
    print(SUPPORTED_COMBINATIONS)
