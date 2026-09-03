from __future__ import annotations

import csv
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCRIPT_PATH = Path(__file__).resolve()
REPOSITORY_ROOT = SCRIPT_PATH.parents[3]
UNIVERSE_ROOT = REPOSITORY_ROOT / "Industrial-Data-Universe"
CONFIG_PATH = UNIVERSE_ROOT / "Config" / "foundation-generator-config-v1.json"
CONTRACT_PATH = UNIVERSE_ROOT / "Schemas" / "foundation-dataset-contract-v1.json"
RULES_PATH = UNIVERSE_ROOT / "Schemas" / "foundation-validation-rules-v1.json"
BLUEPRINT_PATH = UNIVERSE_ROOT / "Blueprint" / "industrial-data-universe-blueprint-v1.json"
DATASETS_ROOT = UNIVERSE_ROOT / "Datasets" / "Foundation"
VALID_DIRECTORY = DATASETS_ROOT / "Valid"
INVALID_DIRECTORY = DATASETS_ROOT / "Invalid"
VALIDATION_DIRECTORY = DATASETS_ROOT / "Validation"
MANIFEST_PATH = VALIDATION_DIRECTORY / "foundation-dataset-manifest-v1.json"
REPORT_PATH = VALIDATION_DIRECTORY / "foundation-dataset-validation-report-v1.md"


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8-sig") as file:
        return json.load(file)


def load_csv(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file, delimiter=",")
        rows = list(reader)
        return reader.fieldnames or [], rows


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def key(row: dict[str, str], columns: list[str]) -> tuple[str, ...]:
    return tuple(row.get(column, "") for column in columns)


def duplicate_keys(rows: list[dict[str, str]], columns: list[str]) -> list[tuple[str, ...]]:
    seen: set[tuple[str, ...]] = set()
    duplicates: set[tuple[str, ...]] = set()
    for row in rows:
        current = key(row, columns)
        if current in seen:
            duplicates.add(current)
        seen.add(current)
    return sorted(duplicates)


def volume_errors(dataset_id: str, count: int, rules: list[dict[str, Any]]) -> list[str]:
    errors: list[str] = []
    rule = next((item for item in rules if item["dataset_id"] == dataset_id), None)
    if rule is None:
        return [f"VOLUME_RULE_NOT_FOUND: {dataset_id}"]
    if "exact_count" in rule and count != int(rule["exact_count"]):
        errors.append(f"INVALID_EXACT_VOLUME: expected={rule['exact_count']}, actual={count}")
    if "minimum_count" in rule and count < int(rule["minimum_count"]):
        errors.append(f"VOLUME_BELOW_MINIMUM: minimum={rule['minimum_count']}, actual={count}")
    if "maximum_count" in rule and count > int(rule["maximum_count"]):
        errors.append(f"VOLUME_ABOVE_MAXIMUM: maximum={rule['maximum_count']}, actual={count}")
    return errors


def foreign_key_errors(dataset: dict[str, Any], rows: list[dict[str, str]], loaded: dict[str, list[dict[str, str]]]) -> list[str]:
    errors: list[str] = []
    for foreign_key in dataset["foreign_keys"]:
        parent_rows = loaded.get(foreign_key["referenced_dataset"], [])
        parent_keys = {key(row, foreign_key["referenced_columns"]) for row in parent_rows}
        for row_number, row in enumerate(rows, start=2):
            child_key = key(row, foreign_key["source_columns"])
            if child_key not in parent_keys:
                errors.append(f"ORPHAN_FOREIGN_KEY: constraint={foreign_key['name']}, row={row_number}, key={child_key}")
    return errors


def business_rule_errors(rule: dict[str, Any], rows: list[dict[str, str]], capabilities: dict[str, set[str]]) -> list[str]:
    errors: list[str] = []
    rule_type = rule["validation_type"]
    if rule_type == "EXACT_LENGTH":
        column = rule["columns"][0]
        expected = int(rule["expected_length"])
        for row_number, row in enumerate(rows, start=2):
            if len(row.get(column, "")) != expected:
                errors.append(f"{rule['rule_id']}: row={row_number}, column={column}")
    elif rule_type == "PREFIX_IN_SET":
        column = rule["columns"][0]
        prefixes = tuple(rule["allowed_prefixes"])
        for row_number, row in enumerate(rows, start=2):
            if not row.get(column, "").startswith(prefixes):
                errors.append(f"{rule['rule_id']}: row={row_number}, value={row.get(column, '')}")
    elif rule_type == "PREFIX_VALUE_MAPPING":
        source_column, value_column = rule["columns"]
        for row_number, row in enumerate(rows, start=2):
            source = row.get(source_column, "")
            prefix = next((item for item in rule["mapping"] if source.startswith(item)), None)
            if prefix is None or row.get(value_column, "") not in rule["mapping"].get(prefix, []):
                errors.append(f"{rule['rule_id']}: row={row_number}, material={source}")
    elif rule_type == "VALUE_IN_SET":
        column = rule["columns"][0]
        allowed = set(rule["allowed_values"])
        for row_number, row in enumerate(rows, start=2):
            if row.get(column, "") not in allowed:
                errors.append(f"{rule['rule_id']}: row={row_number}, value={row.get(column, '')}")
    elif rule_type == "CONDITIONAL_PLANT_CAPABILITY":
        condition_column, condition_value = next(iter(rule["condition"].items()))
        required = rule["required_capability"]
        for row_number, row in enumerate(rows, start=2):
            if row.get(condition_column) == condition_value and required not in capabilities.get(row.get("WERKS", ""), set()):
                errors.append(f"{rule['rule_id']}: row={row_number}, plant={row.get('WERKS', '')}")
    else:
        errors.append(f"UNSUPPORTED_BUSINESS_RULE: {rule['rule_id']}")
    return errors


def validate_valid_datasets(contract: dict[str, Any], rules: dict[str, Any], blueprint: dict[str, Any]) -> tuple[list[dict[str, Any]], dict[str, list[dict[str, str]]]]:
    results: list[dict[str, Any]] = []
    loaded: dict[str, list[dict[str, str]]] = {}
    capabilities = {plant["werks"]: set(plant["multifunctional_processes"]) for plant in blueprint["plants"]}
    for dataset in sorted(contract["datasets"], key=lambda item: int(item["sequence"])):
        dataset_id = dataset["dataset_id"]
        path = VALID_DIRECTORY / dataset["file_name"]
        errors: list[str] = []
        if not path.exists():
            results.append({"dataset_id": dataset_id, "file_name": dataset["file_name"], "target_table": dataset["target_table"], "row_count": 0, "status": "FAILED", "errors": [f"FILE_NOT_FOUND: {path}"]})
            continue
        headers, rows = load_csv(path)
        loaded[dataset_id] = rows
        expected_headers = [column["name"] for column in sorted(dataset["columns"], key=lambda item: int(item["position"]))]
        if headers != expected_headers:
            errors.append(f"COLUMN_ORDER_MISMATCH: expected={expected_headers}, actual={headers}")
        for row_number, row in enumerate(rows, start=2):
            for column in dataset["columns"]:
                value = row.get(column["name"], "") or ""
                if column.get("required") and not value.strip():
                    errors.append(f"BLANK_REQUIRED_FIELD: row={row_number}, column={column['name']}")
                if "maximum_length" in column and len(value) > int(column["maximum_length"]):
                    errors.append(f"MAXIMUM_LENGTH_EXCEEDED: row={row_number}, column={column['name']}")
                if "allowed_values" in column and value not in set(column["allowed_values"]):
                    errors.append(f"VALUE_OUTSIDE_ALLOWED_SET: row={row_number}, column={column['name']}, value={value}")
        for duplicate in duplicate_keys(rows, dataset["primary_key"]):
            errors.append(f"DUPLICATE_PRIMARY_KEY: key={duplicate}")
        errors.extend(volume_errors(dataset_id, len(rows), rules["volume_rules"]))
        errors.extend(foreign_key_errors(dataset, rows, loaded))
        for rule in rules["business_rules"]:
            if rule["dataset_id"] == dataset_id:
                errors.extend(business_rule_errors(rule, rows, capabilities))
        results.append({"dataset_id": dataset_id, "file_name": dataset["file_name"], "target_table": dataset["target_table"], "row_count": len(rows), "primary_key": dataset["primary_key"], "foreign_key_count": len(dataset["foreign_keys"]), "sha256": sha256(path), "size_bytes": path.stat().st_size, "status": "PASSED" if not errors else "FAILED", "errors": errors})
    return results, loaded


def validate_negative_tests(contract: dict[str, Any], rules: dict[str, Any], loaded: dict[str, list[dict[str, str]]]) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    by_dataset = {dataset["dataset_id"]: dataset for dataset in contract["datasets"]}
    for expectation in rules["negative_test_expectations"]:
        path = INVALID_DIRECTORY / expectation["file_name"]
        dataset = by_dataset[expectation["expected_dataset"]]
        if not path.exists():
            results.append({"file_name": expectation["file_name"], "dataset_id": dataset["dataset_id"], "expected_failure": expectation["expected_failure"], "status": "FAILED", "details": "FILE_NOT_FOUND"})
            continue
        _, rows = load_csv(path)
        expected = expectation["expected_failure"]
        if expected == "DUPLICATE_PRIMARY_KEY":
            detected = bool(duplicate_keys(rows, dataset["primary_key"]))
            details = "DUPLICATE_PRIMARY_KEY detected" if detected else "Expected duplicate not detected"
        elif expected in {"ORPHAN_FOREIGN_KEY", "ORPHAN_COMPOSITE_FOREIGN_KEY"}:
            detected_errors = foreign_key_errors(dataset, rows, loaded)
            detected = bool(detected_errors)
            details = detected_errors[0] if detected else "Expected orphan not detected"
        else:
            detected = False
            details = f"Unsupported expected failure: {expected}"
        results.append({"file_name": expectation["file_name"], "dataset_id": dataset["dataset_id"], "expected_failure": expected, "row_count": len(rows), "sha256": sha256(path), "size_bytes": path.stat().st_size, "status": "PASSED" if detected else "FAILED", "details": details})
    return results


def build_manifest(config: dict[str, Any], contract: dict[str, Any], rules: dict[str, Any], valid_results: list[dict[str, Any]], negative_results: list[dict[str, Any]]) -> dict[str, Any]:
    passed = all(item["status"] == "PASSED" for item in valid_results + negative_results)
    return {"manifest": {"id": "FOUNDATION_DATASET_MANIFEST_V1", "version": "1.0.0", "generated_at_utc": datetime.now(timezone.utc).isoformat(), "laboratory": config["configuration"]["laboratory"], "target_schema": config["configuration"]["target_schema"], "seed": config["configuration"]["seed"], "configuration_id": config["configuration"]["id"], "contract_id": contract["contract"]["id"], "validation_rules_id": rules["validation_rules"]["id"], "overall_status": "PASSED" if passed else "FAILED"}, "valid_datasets": valid_results, "negative_tests": negative_results}


def markdown_report(manifest: dict[str, Any]) -> str:
    metadata = manifest["manifest"]
    lines = ["# Foundation Dataset Validation Report v1", "", f"**Laboratory:** `{metadata['laboratory']}`", f"**Target schema:** `{metadata['target_schema']}`", f"**Seed:** `{metadata['seed']}`", f"**Overall status:** `{metadata['overall_status']}`", f"**Generated at UTC:** `{metadata['generated_at_utc']}`", "", "## Valid datasets", "", "| Dataset | File | Rows | Size | Status | SHA-256 |", "|---|---|---:|---:|---|---|"]
    for result in manifest["valid_datasets"]:
        lines.append(f"| `{result['dataset_id']}` | `{result['file_name']}` | {result['row_count']} | {result.get('size_bytes', 0)} | {result['status']} | `{result.get('sha256', '')}` |")
    lines.extend(["", "## Negative tests", "", "| File | Dataset | Expected failure | Rows | Status |", "|---|---|---|---:|---|"])
    for result in manifest["negative_tests"]:
        lines.append(f"| `{result['file_name']}` | `{result['dataset_id']}` | `{result['expected_failure']}` | {result.get('row_count', 0)} | {result['status']} |")
    errors = [(result["dataset_id"], error) for result in manifest["valid_datasets"] for error in result.get("errors", [])]
    failed_negative = [result for result in manifest["negative_tests"] if result["status"] != "PASSED"]
    lines.extend(["", "## Validation details", ""])
    if not errors and not failed_negative:
        lines.append("All valid datasets passed structural, volume, Primary Key, Foreign Key, length, allowed-value, and business-rule validations.")
        lines.append("")
        lines.append("All negative-test datasets failed for their intended validation reason.")
    else:
        for dataset_id, error in errors:
            lines.append(f"- `{dataset_id}`: {error}")
        for result in failed_negative:
            lines.append(f"- `{result['file_name']}`: {result['details']}")
    return "\n".join(lines) + "\n"


def print_summary(manifest: dict[str, Any]) -> None:
    metadata = manifest["manifest"]
    print("Foundation Dataset Validation Engine v1")
    print("=" * 78)
    print(f"Laboratory : {metadata['laboratory']}")
    print(f"Schema     : {metadata['target_schema']}")
    print(f"Seed       : {metadata['seed']}")
    print("-" * 78)
    for result in manifest["valid_datasets"]:
        print(f"{result['dataset_id']:<30}{result['row_count']:>8}  {result['status']}")
    print("-" * 78)
    for result in manifest["negative_tests"]:
        print(f"{result['file_name']:<48}{result['status']}")
    print("-" * 78)
    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Report  : {REPORT_PATH}")
    print(f"Overall validation status: {metadata['overall_status']}")


def main() -> None:
    config = load_json(CONFIG_PATH)
    contract = load_json(CONTRACT_PATH)
    rules = load_json(RULES_PATH)
    blueprint = load_json(BLUEPRINT_PATH)
    VALIDATION_DIRECTORY.mkdir(parents=True, exist_ok=True)
    valid_results, loaded = validate_valid_datasets(contract, rules, blueprint)
    negative_results = validate_negative_tests(contract, rules, loaded)
    manifest = build_manifest(config, contract, rules, valid_results, negative_results)
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    REPORT_PATH.write_text(markdown_report(manifest), encoding="utf-8")
    print_summary(manifest)
    if manifest["manifest"]["overall_status"] != "PASSED":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
