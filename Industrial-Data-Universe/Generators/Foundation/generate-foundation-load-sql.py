from __future__ import annotations

import csv
import json
from pathlib import Path
from typing import Any

SCRIPT_PATH = Path(__file__).resolve()
REPOSITORY_ROOT = SCRIPT_PATH.parents[3]
UNIVERSE_ROOT = REPOSITORY_ROOT / "Industrial-Data-Universe"
DATASETS_ROOT = UNIVERSE_ROOT / "Datasets" / "Foundation"
VALID_DIRECTORY = DATASETS_ROOT / "Valid"
VALIDATION_DIRECTORY = DATASETS_ROOT / "Validation"
LOAD_DIRECTORY = DATASETS_ROOT / "Load"
MANIFEST_PATH = VALIDATION_DIRECTORY / "foundation-dataset-manifest-v1.json"

LOAD_PLAN = [
    {"sequence": 1, "csv": "01-plants.csv", "sql": "01-load-plants.sql", "table": "LAB_A1.PLANT", "columns": ["WERKS", "PLANT_NAME", "COUNTRY"]},
    {"sequence": 2, "csv": "02-materials.csv", "sql": "02-load-materials.sql", "table": "LAB_A1.MATERIAL", "columns": ["MATNR", "DESCRIPTION", "MTART", "MATKL", "MEINS"]},
    {"sequence": 3, "csv": "03-storage-locations.csv", "sql": "03-load-storage-locations.sql", "table": "LAB_A1.STORAGE_LOCATION", "columns": ["WERKS", "LGORT", "STORAGE_LOCATION_NAME"]},
    {"sequence": 4, "csv": "04-material-plants.csv", "sql": "04-load-material-plants.sql", "table": "LAB_A1.MATERIAL_PLANT", "columns": ["MATNR", "WERKS", "PROCUREMENT_TYPE", "MRP_TYPE"]},
    {"sequence": 5, "csv": "05-material-storage-locations.csv", "sql": "05-load-material-storage-locations.sql", "table": "LAB_A1.MATERIAL_STORAGE_LOCATION", "columns": ["MATNR", "WERKS", "LGORT", "STORAGE_STATUS"]},
]


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8-sig") as file:
        return json.load(file)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as file:
        return list(csv.DictReader(file, delimiter=","))


def sql_literal(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def insert_statement(table: str, columns: list[str], row: dict[str, str]) -> str:
    column_list = ", ".join(columns)
    value_list = ", ".join(sql_literal(row[column]) for column in columns)
    return f"INSERT INTO {table} ({column_list}) VALUES ({value_list});"


def build_load_file(item: dict[str, Any], rows: list[dict[str, str]]) -> str:
    lines = [
        f"-- Foundation Dataset Load v1 - Step {item['sequence']}",
        f"-- Source: {item['csv']}",
        f"-- Target: {item['table']}",
        f"-- Expected rows: {len(rows)}",
        "",
    ]
    lines.extend(insert_statement(item["table"], item["columns"], row) for row in rows)
    lines.extend(["", "COMMIT;", "", f"SELECT '{item['table']}' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM {item['table']};"])
    return "\n".join(lines) + "\n"


def build_validation_file() -> str:
    lines = [
        "-- Foundation Dataset Load v1 - Final validation",
        "SELECT 'PLANT' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM LAB_A1.PLANT",
        "UNION ALL",
        "SELECT 'MATERIAL', COUNT(*) FROM LAB_A1.MATERIAL",
        "UNION ALL",
        "SELECT 'STORAGE_LOCATION', COUNT(*) FROM LAB_A1.STORAGE_LOCATION",
        "UNION ALL",
        "SELECT 'MATERIAL_PLANT', COUNT(*) FROM LAB_A1.MATERIAL_PLANT",
        "UNION ALL",
        "SELECT 'MATERIAL_STORAGE_LOCATION', COUNT(*) FROM LAB_A1.MATERIAL_STORAGE_LOCATION",
        "ORDER BY TABLE_NAME;",
    ]
    return "\n".join(lines) + "\n"


def main() -> None:
    manifest = load_json(MANIFEST_PATH)
    status = manifest["manifest"]["overall_status"]
    if status != "PASSED":
        raise SystemExit(f"Manifest status must be PASSED. Actual status: {status}")
    expected_counts = {item["file_name"]: int(item["row_count"]) for item in manifest["valid_datasets"]}
    LOAD_DIRECTORY.mkdir(parents=True, exist_ok=True)
    generated: list[tuple[str, int, int]] = []
    for item in LOAD_PLAN:
        csv_path = VALID_DIRECTORY / item["csv"]
        if not csv_path.exists():
            raise FileNotFoundError(csv_path)
        rows = read_csv(csv_path)
        expected = expected_counts.get(item["csv"])
        if expected is None:
            raise SystemExit(f"File not found in manifest: {item['csv']}")
        if len(rows) != expected:
            raise SystemExit(f"Row-count mismatch for {item['csv']}: expected={expected}, actual={len(rows)}")
        sql_path = LOAD_DIRECTORY / item["sql"]
        sql_path.write_text(build_load_file(item, rows), encoding="utf-8")
        generated.append((item["sql"], len(rows), sql_path.stat().st_size))
    validation_path = LOAD_DIRECTORY / "06-validate-foundation-load.sql"
    validation_path.write_text(build_validation_file(), encoding="utf-8")
    print("Foundation SQL Load Generator v1")
    print("=" * 78)
    print(f"Manifest status: {status}")
    print(f"Laboratory     : {manifest['manifest']['laboratory']}")
    print(f"Target schema  : {manifest['manifest']['target_schema']}")
    print(f"Seed           : {manifest['manifest']['seed']}")
    print("-" * 78)
    for file_name, row_count, size_bytes in generated:
        print(f"{file_name:<44}{row_count:>8} rows  {size_bytes:>9} bytes")
    print(f"{'06-validate-foundation-load.sql':<44}{validation_path.stat().st_size:>19} bytes")
    print("-" * 78)
    print(f"Output: {LOAD_DIRECTORY}")
    print("Generation status: COMPLETED")


if __name__ == "__main__":
    main()
