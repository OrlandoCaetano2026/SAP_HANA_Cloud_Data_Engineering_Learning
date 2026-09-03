from __future__ import annotations

import csv
import json
import random
from pathlib import Path
from typing import Any

SCRIPT_PATH = Path(__file__).resolve()
REPOSITORY_ROOT = SCRIPT_PATH.parents[3]
UNIVERSE_ROOT = REPOSITORY_ROOT / "Industrial-Data-Universe"

BLUEPRINT_PATH = (
    UNIVERSE_ROOT
    / "Blueprint"
    / "industrial-data-universe-blueprint-v1.json"
)

CONFIG_PATH = (
    UNIVERSE_ROOT
    / "Config"
    / "foundation-generator-config-v1.json"
)

CONTRACT_PATH = (
    UNIVERSE_ROOT
    / "Schemas"
    / "foundation-dataset-contract-v1.json"
)

RULES_PATH = (
    UNIVERSE_ROOT
    / "Schemas"
    / "foundation-validation-rules-v1.json"
)

OUTPUT_ROOT = UNIVERSE_ROOT / "Datasets" / "Foundation"
VALID_DIRECTORY = OUTPUT_ROOT / "Valid"
INVALID_DIRECTORY = OUTPUT_ROOT / "Invalid"


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8-sig") as file:
        return json.load(file)


def write_csv(
    path: Path,
    fieldnames: list[str],
    rows: list[dict[str, str]]
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open(
        "w",
        encoding="utf-8",
        newline=""
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames,
            delimiter=",",
            lineterminator="\n"
        )
        writer.writeheader()
        writer.writerows(rows)


def material_group(
    family_prefix: str,
    sequence: int
) -> str:
    groups = {
        "RM": [
            "METALS",
            "POLYMERS",
            "CHEMICALS",
            "CABLES",
            "FASTENERS"
        ],
        "EC": [
            "SENSORS",
            "CONTROLS",
            "DISPLAYS",
            "POWER",
            "COMM"
        ],
        "MC": [
            "FRAMES",
            "SHAFTS",
            "GEARS",
            "HOUSINGS",
            "BEARINGS"
        ],
        "SA": [
            "ASSEMBLY",
            "MODULE",
            "SUBSYS"
        ],
        "FG": [
            "SYSTEMS",
            "EQUIPMENT",
            "SOLUTIONS"
        ],
        "PK": [
            "PACKAGING",
            "LABELS",
            "PROTECT"
        ]
    }

    values = groups[family_prefix]
    return values[(sequence - 1) % len(values)]


def base_unit(family_prefix: str, sequence: int) -> str:
    if family_prefix == "RM":
        values = ["KG", "M", "L", "EA"]
    elif family_prefix == "PK":
        values = ["EA", "M", "KG"]
    else:
        values = ["EA"]

    return values[(sequence - 1) % len(values)]


def material_description(
    family_prefix: str,
    sequence: int
) -> str:
    descriptions = {
        "RM": "Industrial Raw Material",
        "EC": "Electronic Component",
        "MC": "Mechanical Component",
        "SA": "Semifinished Assembly",
        "FG": "Finished Industrial Product",
        "PK": "Packaging Material"
    }

    return f"{descriptions[family_prefix]} {sequence:03d}"


def generate_plants(
    blueprint: dict[str, Any]
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []

    for plant in blueprint["plants"]:
        rows.append(
            {
                "WERKS": plant["werks"],
                "PLANT_NAME": plant["plant_name"],
                "COUNTRY": plant["country"]
            }
        )

    return rows


def generate_materials(
    blueprint: dict[str, Any]
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []

    for family in blueprint["material_families"]:
        prefix = family["prefix"]
        count = int(family["count"])
        mtart = family["default_mtart"]

        numeric_base = {
            "RM": 100000,
            "EC": 200000,
            "MC": 300000,
            "SA": 400000,
            "FG": 500000,
            "PK": 600000
        }[prefix]

        for sequence in range(1, count + 1):
            rows.append(
                {
                    "MATNR": (
                        f"{prefix}-{numeric_base + sequence:06d}"
                    ),
                    "DESCRIPTION": material_description(
                        prefix,
                        sequence
                    ),
                    "MTART": mtart,
                    "MATKL": material_group(
                        prefix,
                        sequence
                    ),
                    "MEINS": base_unit(
                        prefix,
                        sequence
                    )
                }
            )

    return rows


def generate_storage_locations(
    blueprint: dict[str, Any]
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    templates = blueprint["storage_location_templates"]

    for plant in blueprint["plants"]:
        profile_code = plant["profile_code"]
        plant_templates = templates[profile_code]

        for lgort, storage_location_name in plant_templates:
            rows.append(
                {
                    "WERKS": plant["werks"],
                    "LGORT": lgort,
                    "STORAGE_LOCATION_NAME": (
                        storage_location_name
                    )
                }
            )

    return rows


def determine_procurement_type(
    material_number: str,
    plant: dict[str, Any],
    random_generator: random.Random
) -> str:
    prefix = material_number.split("-")[0]
    capabilities = set(plant["multifunctional_processes"])

    if prefix in {"SA", "FG"} and "PRODUCTION" in capabilities:
        return "E"

    if prefix in {"RM", "EC", "MC", "PK"}:
        return "F"

    return random_generator.choice(["F", "X"])


def determine_mrp_type(
    procurement_type: str,
    random_generator: random.Random
) -> str:
    if procurement_type == "E":
        return random_generator.choice(["PD", "PD", "PD", "VB"])

    if procurement_type == "F":
        return random_generator.choice(["PD", "VB", "VB"])

    return "ND"


def generate_material_plants(
    materials: list[dict[str, str]],
    blueprint: dict[str, Any],
    random_generator: random.Random
) -> list[dict[str, str]]:
    plants = blueprint["plants"]
    rows: list[dict[str, str]] = []

    for material in materials:
        prefix = material["MATNR"].split("-")[0]

        if prefix in {"FG", "SA"}:
            minimum_assignments = 3
            maximum_assignments = 5
        elif prefix in {"RM", "EC", "MC"}:
            minimum_assignments = 3
            maximum_assignments = 4
        else:
            minimum_assignments = 2
            maximum_assignments = 4

        assignment_count = random_generator.randint(
            minimum_assignments,
            maximum_assignments
        )

        if prefix in {"FG", "SA"}:
            manufacturing_plants = [
                plant
                for plant in plants
                if "PRODUCTION"
                in plant["multifunctional_processes"]
            ]

            selected = random_generator.sample(
                manufacturing_plants,
                min(
                    assignment_count,
                    len(manufacturing_plants)
                )
            )
        else:
            selected = random_generator.sample(
                plants,
                assignment_count
            )

        for plant in selected:
            procurement_type = determine_procurement_type(
                material["MATNR"],
                plant,
                random_generator
            )

            rows.append(
                {
                    "MATNR": material["MATNR"],
                    "WERKS": plant["werks"],
                    "PROCUREMENT_TYPE": procurement_type,
                    "MRP_TYPE": determine_mrp_type(
                        procurement_type,
                        random_generator
                    )
                }
            )

    rows.sort(
        key=lambda row: (
            row["MATNR"],
            row["WERKS"]
        )
    )

    return rows


def allowed_storage_locations(
    material_number: str,
    plant_werks: str,
    storage_locations: list[dict[str, str]]
) -> list[dict[str, str]]:
    prefix = material_number.split("-")[0]

    plant_locations = [
        row
        for row in storage_locations
        if row["WERKS"] == plant_werks
    ]

    preferred_names = {
        "RM": {
            "Raw Materials",
            "General Warehouse",
            "Prototype Materials",
            "Repair Components",
            "Incoming Samples",
            "Quality Inspection",
            "Inspection Area"
        },
        "EC": {
            "Electronic Components",
            "General Warehouse",
            "Prototype Materials",
            "Repair Components",
            "Quality Inspection",
            "Inspection Area"
        },
        "MC": {
            "Mechanical Components",
            "General Warehouse",
            "Prototype Materials",
            "Repair Components",
            "Quality Inspection",
            "Inspection Area"
        },
        "SA": {
            "Production Supply",
            "Work in Process",
            "General Warehouse",
            "Prototype Assembly",
            "Refurbished Equipment",
            "Quality Inspection"
        },
        "FG": {
            "Finished Goods",
            "General Warehouse",
            "Completed Prototypes",
            "Refurbished Equipment",
            "Picking Area",
            "Shipping Area"
        },
        "PK": {
            "Raw Materials",
            "General Warehouse",
            "Packing Area",
            "Production Supply",
            "Shipping Area"
        }
    }

    preferred = preferred_names[prefix]

    eligible = [
        row
        for row in plant_locations
        if row["STORAGE_LOCATION_NAME"] in preferred
    ]

    return eligible or plant_locations


def generate_material_storage_locations(
    material_plants: list[dict[str, str]],
    storage_locations: list[dict[str, str]],
    random_generator: random.Random
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []

    for material_plant in material_plants:
        eligible_locations = allowed_storage_locations(
            material_plant["MATNR"],
            material_plant["WERKS"],
            storage_locations
        )

        maximum_assignment = min(
            3,
            len(eligible_locations)
        )

        assignment_count = random_generator.randint(
            2 if maximum_assignment >= 2 else 1,
            maximum_assignment
        )

        selected_locations = random_generator.sample(
            eligible_locations,
            assignment_count
        )

        for storage_location in selected_locations:
            status = (
                "I"
                if random_generator.random() < 0.05
                else "A"
            )

            rows.append(
                {
                    "MATNR": material_plant["MATNR"],
                    "WERKS": material_plant["WERKS"],
                    "LGORT": storage_location["LGORT"],
                    "STORAGE_STATUS": status
                }
            )

    rows.sort(
        key=lambda row: (
            row["MATNR"],
            row["WERKS"],
            row["LGORT"]
        )
    )

    return rows


def generate_invalid_datasets(
    plants: list[dict[str, str]],
    materials: list[dict[str, str]],
    storage_locations: list[dict[str, str]],
    material_plants: list[dict[str, str]],
    material_storage_locations: list[dict[str, str]]
) -> None:
    duplicate_plant = [
        plants[0],
        plants[0]
    ]

    duplicate_material = [
        materials[0],
        materials[0]
    ]

    orphan_storage_location = [
        {
            "WERKS": "9999",
            "LGORT": "0001",
            "STORAGE_LOCATION_NAME": (
                "Invalid Orphan Storage Location"
            )
        }
    ]

    orphan_material_plant = [
        {
            "MATNR": "FG-999999",
            "WERKS": plants[0]["WERKS"],
            "PROCUREMENT_TYPE": "E",
            "MRP_TYPE": "PD"
        }
    ]

    orphan_material_storage_location = [
        {
            "MATNR": material_storage_locations[0]["MATNR"],
            "WERKS": material_storage_locations[0]["WERKS"],
            "LGORT": "9999",
            "STORAGE_STATUS": "A"
        }
    ]

    write_csv(
        INVALID_DIRECTORY / "01-duplicate-plant.csv",
        ["WERKS", "PLANT_NAME", "COUNTRY"],
        duplicate_plant
    )

    write_csv(
        INVALID_DIRECTORY / "02-duplicate-material.csv",
        [
            "MATNR",
            "DESCRIPTION",
            "MTART",
            "MATKL",
            "MEINS"
        ],
        duplicate_material
    )

    write_csv(
        INVALID_DIRECTORY
        / "03-orphan-storage-location.csv",
        [
            "WERKS",
            "LGORT",
            "STORAGE_LOCATION_NAME"
        ],
        orphan_storage_location
    )

    write_csv(
        INVALID_DIRECTORY
        / "04-orphan-material-plant.csv",
        [
            "MATNR",
            "WERKS",
            "PROCUREMENT_TYPE",
            "MRP_TYPE"
        ],
        orphan_material_plant
    )

    write_csv(
        INVALID_DIRECTORY
        / "05-orphan-material-storage-location.csv",
        [
            "MATNR",
            "WERKS",
            "LGORT",
            "STORAGE_STATUS"
        ],
        orphan_material_storage_location
    )


def main() -> None:
    blueprint = load_json(BLUEPRINT_PATH)
    config = load_json(CONFIG_PATH)
    contract = load_json(CONTRACT_PATH)
    rules = load_json(RULES_PATH)

    seed = int(config["configuration"]["seed"])
    random_generator = random.Random(seed)

    VALID_DIRECTORY.mkdir(parents=True, exist_ok=True)
    INVALID_DIRECTORY.mkdir(parents=True, exist_ok=True)

    plants = generate_plants(blueprint)
    materials = generate_materials(blueprint)
    storage_locations = generate_storage_locations(
        blueprint
    )

    material_plants = generate_material_plants(
        materials,
        blueprint,
        random_generator
    )

    material_storage_locations = (
        generate_material_storage_locations(
            material_plants,
            storage_locations,
            random_generator
        )
    )

    write_csv(
        VALID_DIRECTORY / "01-plants.csv",
        ["WERKS", "PLANT_NAME", "COUNTRY"],
        plants
    )

    write_csv(
        VALID_DIRECTORY / "02-materials.csv",
        [
            "MATNR",
            "DESCRIPTION",
            "MTART",
            "MATKL",
            "MEINS"
        ],
        materials
    )

    write_csv(
        VALID_DIRECTORY / "03-storage-locations.csv",
        [
            "WERKS",
            "LGORT",
            "STORAGE_LOCATION_NAME"
        ],
        storage_locations
    )

    write_csv(
        VALID_DIRECTORY / "04-material-plants.csv",
        [
            "MATNR",
            "WERKS",
            "PROCUREMENT_TYPE",
            "MRP_TYPE"
        ],
        material_plants
    )

    write_csv(
        VALID_DIRECTORY
        / "05-material-storage-locations.csv",
        [
            "MATNR",
            "WERKS",
            "LGORT",
            "STORAGE_STATUS"
        ],
        material_storage_locations
    )

    generate_invalid_datasets(
        plants,
        materials,
        storage_locations,
        material_plants,
        material_storage_locations
    )

    counts = {
        "PLANTS": len(plants),
        "MATERIALS": len(materials),
        "STORAGE_LOCATIONS": len(storage_locations),
        "MATERIAL_PLANTS": len(material_plants),
        "MATERIAL_STORAGE_LOCATIONS": len(
            material_storage_locations
        )
    }

    print("")
    print("Foundation Generator v1")
    print("=" * 72)
    print(f"Blueprint : {blueprint['blueprint']['id']}")
    print(f"Config    : {config['configuration']['id']}")
    print(f"Contract  : {contract['contract']['id']}")
    print(
        f"Rules     : "
        f"{rules['validation_rules']['id']}"
    )
    print(f"Laboratory: {config['configuration']['laboratory']}")
    print(f"Seed      : {seed}")
    print("-" * 72)

    for dataset_id, count in counts.items():
        print(f"{dataset_id:<30} {count:>8}")

    print("-" * 72)
    print(f"Valid output  : {VALID_DIRECTORY}")
    print(f"Invalid output: {INVALID_DIRECTORY}")
    print("Generation status: COMPLETED")


if __name__ == "__main__":
    main()