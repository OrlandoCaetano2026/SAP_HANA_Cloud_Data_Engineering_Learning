# C11: CAP & Modern CDS (`@sap/cds-dk`)

**🌐 Language / Idioma:** 🇺🇸 **English** | [🇧🇷 Português](../BR/02-c11-cap-e-cds-moderno.md)

[⬆️ Back to README](../../../README.md) | [⬅️ Previous: C1 to C10](./01-c1-c10-professional-environment-and-hdi-security.en.md)

> **Status:** ✅ Completed locally (CDS model + SQLite + OData service) · ⚪ HANA Cloud deployment not tested
> **Environment:** SAP Business Application Studio (BAS) · Dev Space `industrial_data_hana` · Node.js 24.17.0 · `@sap/cds-dk` 10.1.0
> **Project:** `industrial_data_cap` (separate from the HDI project `industrial_data_db`, in BAS under `/home/user/projects/`)
> **Classification:** educational development environment, fictional data

## 🎯 Executive overview

In C5, classic CDS (`.hdbcds`) ran into a plugin that no longer exists in the HANA Cloud deploy engine. C11 closes that gap through today's official path: **CAP (Cloud Application Programming Model)**, with its own CLI (`@sap/cds-dk`), `.cds` files without the `hdb` prefix, and a service that exposes the data as an OData API.

The outcome was a full cycle, validated end to end in the local BAS environment: **data model → database → service → API → inserting and reading back a record**.

| Step | Result |
|---|---|
| CLI installed | ✅ `@sap/cds-dk` 10.1.0 (Node 24.17.0, npm 11.13.0) |
| CAP project created | ✅ `industrial_data_cap` with `db/`, `srv/`, `app/` |
| Data model (`db/schema.cds`) | ✅ `Suppliers` entity |
| Service (`srv/service.cds`) | ✅ `SupplierService` exposing `Suppliers` |
| Local SQLite database | ✅ `cds deploy --to sqlite:db/supplier.sqlite` |
| OData service running | ✅ `/odata/v4/supplier/Suppliers` |
| POST + GET of one record | ✅ `SUP-001` created and read back |
| HANA Cloud deployment | ⚪ Not tested in this round |

---

## 🧭 Functional storytelling

### Preparation: session and cleanup

Before starting, a leftover from the previous block: the service key `my-dev-key-2` (a real HDI Container credential) still existed. The first attempt to delete it failed because the Cloud Foundry session had expired (`The token expired, was revoked`). After a new SSO login, the key was removed and the removal confirmed with `cf service-keys hdi_db` (result: `No service keys for service instance hdi_db`). The `key.json` holding the password in plain text was also deleted.

### Installation and project creation

```bash
npm install -g @sap/cds-dk
cds --version        # @sap/cds-dk 10.1.0 · Node.js 24.17.0
cd /home/user/projects
cds init industrial_data_cap
```

`cds init` reported success but **did not generate `package.json`** (only `readme.md`, `.gitignore`, `.vscode/` and the `db/`, `srv/`, `app/` folders). The project doesn't work without that file, so it was created manually:

```bash
npm init -y
npm install @sap/cds
```

> [!NOTE]
> This `cds init` behavior was observed in this session and was not investigated in depth. If `package.json` is missing in your environment, `npm init -y` + `npm install @sap/cds` fixes it.

### The model and the service

Two layers, each in its own file. Data lives in `db/`, API exposure lives in `srv/`:

```cds
// db/schema.cds
namespace industrial.data.cap;

entity Suppliers {
  key LIFNR      : String(10);
  LIFNR_TEXT     : String(80) not null;
  COUNTRY        : String(3);
}
```

```cds
// srv/service.cds
using { industrial.data.cap as db } from '../db/schema';

service SupplierService {
  entity Suppliers as projection on db.Suppliers;
}
```

![C11-EV02 — db/schema.cds](../../../Evidences/LAB_C/C11-EV02-cds-model-db-schema.png)
*C11-EV02 — Data model: `Suppliers` entity in `db/schema.cds`. Note the `supplier.sqlite` already present in `db/`.*

![C11-EV03 — srv/service.cds](../../../Evidences/LAB_C/C11-EV03-cds-model-srv-service.png)
*C11-EV03 — `SupplierService` in `srv/service.cds`, projecting the model entity.*

The entity reuses the `SUPPLIER` design from Block A (`LIFNR`, `LIFNR_TEXT`, `COUNTRY`), deliberately trimmed to just prove the cycle.

### Local database: two configuration obstacles

```bash
cds add sqlite
cds deploy
```

The first `cds deploy` failed with `Please specify a database kind or url`. With the target made explicit, it failed again, now with `MODULE_NOT_FOUND`. Even though `cds add sqlite` reported `Successfully added features`, the **SQLite driver had not been installed**. The fix was installing it:

```bash
npm install @cap-js/sqlite
cds deploy --to sqlite:db/supplier.sqlite
# /> successfully deployed to db/supplier.sqlite
```

![C11-EV04 — cds deploy](../../../Evidences/LAB_C/C11-EV04-cds-deploy-sqlite-success.png)
*C11-EV04 — `cds deploy --to sqlite:db/supplier.sqlite` completed successfully.*

### Service up and end-to-end proof

```bash
nohup cds serve --port 4004 > server.log 2>&1 &
curl -s http://localhost:4004/odata/v4/supplier/Suppliers
# {"@odata.context":"$metadata#Suppliers","value":[]}

curl -s -X POST http://localhost:4004/odata/v4/supplier/Suppliers \
  -H "Content-Type: application/json" \
  -d '{"LIFNR":"SUP-001","LIFNR_TEXT":"Metal Alloys International 1","COUNTRY":"BRA"}'

curl -s http://localhost:4004/odata/v4/supplier/Suppliers
# {"value":[{"LIFNR":"SUP-001","LIFNR_TEXT":"Metal Alloys International 1","COUNTRY":"BRA"}]}
```

The list started empty, accepted the `POST`, and returned the record on `GET`. The server was then stopped, and a new call failed with `Failed to connect to localhost port 4004`, confirming it was down.

![C11-EV01 — OData service end to end](../../../Evidences/LAB_C/C11-EV01-odata-service-end-to-end.png)
*C11-EV01 — `server.log` with both CDS files loaded and the service at `/odata/v4/supplier`, plus the POST, GET and shutdown in the terminal.*

> [!IMPORTANT]
> `server.log` shows `connect to db > sqlite { url: ':memory:' }` and `using auth strategy { kind: 'mocked' }`. That is, `cds serve` ran with an **in-memory database** (it did not use the `db/supplier.sqlite` file) and **mocked authentication**. The `SUP-001` record exists only while the server is up. This is CAP's default development-mode behavior, not a defect, but keep in mind this is not persistence yet.

---

## ⚖️ Native HDI (C2–C6) × CAP (C11)

| Aspect | Native HDI (earlier Block C) | CAP (C11) |
|---|---|---|
| Model file | `.hdbtable` (SQL DDL) | `.cds` (declarative) |
| Build/deploy tool | `mbt build` + `cf deploy` | `cds deploy` / `cds serve` |
| Namespace | Manual `namespace::object` prefix | `namespace` declared at the top of the file |
| API | None | OData service generated from `srv/` |
| Local testing | None (direct cloud deploy) | In-memory SQLite, cycle in seconds |
| Obstacles hit | HDI privileges, network | Dependencies (`package.json`, SQLite driver) |

---

## 🧱 Generated structure

```text
industrial_data_cap/
├── db/
│   ├── schema.cds          # data model
│   └── supplier.sqlite     # database generated by cds deploy
├── srv/
│   └── service.cds         # OData service
├── app/                    # empty (UI not used)
├── .vscode/
├── package.json            # created manually (npm init -y)
└── readme.md
```

> The project lives in BAS, not in this repository. The `.cds` files are reproduced in full above.

---

## 📸 Evidence

| Evidence | Content |
|---|---|
| `C11-EV01` | `server.log` + POST/GET/shutdown in the terminal |
| `C11-EV02` | `db/schema.cds` with the `Suppliers` entity |
| `C11-EV03` | `srv/service.cds` with `SupplierService` |
| `C11-EV04` | `cds deploy --to sqlite:db/supplier.sqlite` succeeding |

Files in [`Evidences/LAB_C/`](../../../Evidences/LAB_C/).

---

## 🔜 What was left out

- **HANA Cloud deployment (`cds deploy --to hana`)**: not attempted. It would require binding the CAP project to an HDI Container and running from BAS, a path that already showed restrictions in C6/C7.
- **Real persistence**: running `cds serve` against `supplier.sqlite` (or HANA) instead of memory.
- **Real authentication**: the service used mocked authentication.
- **User interface (`app/`)**: folder created empty. Consuming it from SAP Fiori is a Block G topic.

---

[⬆️ Back to README](../../../README.md) | [⬅️ Previous: C1 to C10](./01-c1-c10-professional-environment-and-hdi-security.en.md)
