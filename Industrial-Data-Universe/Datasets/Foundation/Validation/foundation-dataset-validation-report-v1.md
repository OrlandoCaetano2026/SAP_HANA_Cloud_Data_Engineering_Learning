# Foundation Dataset Validation Report v1

**Laboratory:** `LAB_A1`
**Target schema:** `LAB_A1`
**Seed:** `20260903`
**Overall status:** `PASSED`
**Generated at UTC:** `2026-09-03T14:50:39.896629+00:00`

## Valid datasets

| Dataset | File | Rows | Size | Status | SHA-256 |
|---|---|---:|---:|---|---|
| `PLANTS` | `01-plants.csv` | 20 | 737 | PASSED | `66579214870cd337e74d3301118877ac5730ed244194c3054e2e951dfc8ac15d` |
| `MATERIALS` | `02-materials.csv` | 300 | 15644 | PASSED | `d169f14862001df8f12a31d3f120ec90fe575aca88a6a2d78f48b864842df64b` |
| `STORAGE_LOCATIONS` | `03-storage-locations.csv` | 152 | 4171 | PASSED | `84986740102b4be44a3c56a4de6a49797ce3933c979f7dfff7da2fc2edbbeb60` |
| `MATERIAL_PLANTS` | `04-material-plants.csv` | 1080 | 21638 | PASSED | `6972ebf27066f71fc32bb0d148d37550dd902ae864b6b221dc6581381aecd98e` |
| `MATERIAL_STORAGE_LOCATIONS` | `05-material-storage-locations.csv` | 2163 | 47619 | PASSED | `9ca6d88b714b4458d14f81be70ce62de299496bbef8e77b7d01f15a4426acb7b` |

## Negative tests

| File | Dataset | Expected failure | Rows | Status |
|---|---|---|---:|---|
| `01-duplicate-plant.csv` | `PLANTS` | `DUPLICATE_PRIMARY_KEY` | 2 | PASSED |
| `02-duplicate-material.csv` | `MATERIALS` | `DUPLICATE_PRIMARY_KEY` | 2 | PASSED |
| `03-orphan-storage-location.csv` | `STORAGE_LOCATIONS` | `ORPHAN_FOREIGN_KEY` | 1 | PASSED |
| `04-orphan-material-plant.csv` | `MATERIAL_PLANTS` | `ORPHAN_FOREIGN_KEY` | 1 | PASSED |
| `05-orphan-material-storage-location.csv` | `MATERIAL_STORAGE_LOCATIONS` | `ORPHAN_COMPOSITE_FOREIGN_KEY` | 1 | PASSED |

## Validation details

All valid datasets passed structural, volume, Primary Key, Foreign Key, length, allowed-value, and business-rule validations.

All negative-test datasets failed for their intended validation reason.
