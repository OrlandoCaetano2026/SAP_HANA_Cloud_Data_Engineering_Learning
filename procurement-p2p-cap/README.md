# procurement-p2p-cap

Projeto CAP do **Bloco G** (SAP Fiori Data Applications): elegibilidade de fornecedor (PIR + QIR), pedido de compra com itens, aprovação por alçada e integração com o ERP (simulada).

> Ambiente educacional, dados fictícios. Projeto separado do `industrial-data-cap` (Bloco F) para não alterar o modelo que sustenta as evidências do F.

## Subir localmente (SQLite em memória, usuários de teste)

```powershell
npm.cmd install
npx.cmd cds watch
```

Serviço OData V4: `http://localhost:4004/odata/v4/p2p` · usuários locais (só desenvolvimento): `alice` (Buyer), `bob` (Viewer), `carol` (Approver), `dave` (Approver + ApproverSenior); a senha é igual ao nome.

## Aplicações Fiori Elements (G1 e G2)

Com o servidor no ar (`npm.cmd run watch-eligibility`, ou `npx.cmd cds watch`), um único processo serve os dois apps. Abra no navegador (login `bob` / `bob`, papel `Viewer`):

| App | Endereço |
|---|---|
| G1 — Material Master Explorer | `http://localhost:4004/p2p.materials/index.html` |
| G2 — Supplier Eligibility Explorer | `http://localhost:4004/p2p.eligibility/index.html` |

As telas são geradas por anotações CDS (`app/*/annotations*.cds`) lidas pelo Fiori Elements; o JavaScript de tela é só o `Component.js`. O SAPUI5 (1.154.0) é carregado do CDN `sapui5.hana.ondemand.com`. No BTP, os dois apps são módulos HTML5 do mesmo MTA (`mbt.cmd build` e `cf deploy`).

## Modelo

| Grupo | Entidades |
|---|---|
| Códigos e organização | `MaterialType`, `Plant`, `PurchasingOrg`, `SupplierStatus`, `DocType`, `OrderStatus` |
| Dados mestres (cópia somente leitura) | `Material`, `Supplier` (códigos iguais aos do `INDUSTRIAL_DATA`) |
| Info records | `PurchasingInfoRecord` (PIR estendido: moeda, validade, quantidade mínima), `QualityInfoRecord` (QIR: status, motivo de bloqueio, certificado e validade) |
| Pedido e aprovação | `PurchaseOrder` (com rascunho), `PurchaseOrderItem`, `ApprovalRule` (alçada e tolerância), `ApprovalLog` |

`SupplierEligibility` é uma view do serviço (sobre `EligibilityBase`): para cada PIR, devolve `REASON` = `ELIGIBLE`, `SUPPLIER_NOT_ACTIVE`, `PIR_EXPIRED`, `PIR_NOT_YET_VALID`, `QIR_MISSING`, `QIR_BLOCKED` ou `CERT_EXPIRED`.

## Massa de dados (`db/data`)

12 materiais, 10 fornecedores, 30 PIR, 27 QIR, 7 motivos de elegibilidade, 27 regras de alçada e 30 pedidos (59 itens, 55 eventos de histórico) em todos os status do fluxo. As validades dos certificados foram montadas em torno de **2026-11-16** (certificados vencidos, a vencer em 30, 60 e 90 dias, e bloqueados).

## Papéis

`Viewer` lê · `Buyer` cria pedidos · `Approver` e `ApproverSenior` aprovam por alçada. Em produção, os papéis vêm do XSUAA (`xs-security.json`, `xsappname` `procurement-p2p`).

## Não vai para o GitHub

`node_modules/`, `gen/`, `default-env.json`, `.cdsrc-private.json`, `.env`.
