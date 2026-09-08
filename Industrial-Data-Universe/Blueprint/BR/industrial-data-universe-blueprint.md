# Blueprint do Universo de Dados Industriais

**🌐 Idioma / Language:** 🇧🇷 **Português** | [🇺🇸 English](../EN/industrial-data-universe-blueprint.en.md)

> **Versão interna:** `1.3.0`  
> **Status:** ✅ Aprovado para implementação incremental  
> **Última atualização:** `2026-09-08`  
> **Seed determinística:** `20260903`  
> **Companhia:** `Fictional Industrial Manufacturing Group`  
> **Classificação:** dados sintéticos exclusivamente educacionais

## Propósito

O Blueprint governa o universo de dados industriais compartilhado entre os diferentes cenários do projeto. A identidade documental permanece associada a cada DOC e LAB, enquanto os dados físicos evoluem no schema compartilhado `INDUSTRIAL_DATA` do SAP HANA Cloud.

A existência de versões separadas em português e inglês facilita a leitura por públicos diferentes sem duplicar a fonte técnica processável. O arquivo JSON localizado na raiz de `Blueprint/` permanece como fonte canônica para automações, geradores, validadores e futuras aplicações.

## Estado atual do schema

A migration executada no cenário A2 generalizou o nome físico do schema sem alterar a identidade histórica do laboratório A1:

```text
Schema físico anterior:       LAB_A1
Schema físico atual:          INDUSTRIAL_DATA
Status da migration:          APPLIED
Status da validação:          PASSED
```

```mermaid
flowchart LR
    OLD["LAB_A1<br/>Schema de origem do A1"]:::previous
    MIG{"RENAME SCHEMA<br/>Migration executada no A2"}:::migration
    NEW[("INDUSTRIAL_DATA<br/>Schema físico compartilhado")]:::current
    ES["Estrutura Organizacional<br/>A2 validado"]:::done
    MM["Dados Mestre de Material<br/>A3 validado"]:::done
    FUT["Fornecedores MM · PP · QM · WM · MES<br/>Transações · Eventos"]:::future
    OLD --> MIG --> NEW --> ES --> MM --> FUT
    classDef previous fill:#F3F4F6,stroke:#6B7280,color:#374151,stroke-width:2px;
    classDef migration fill:#F3E8FF,stroke:#9333EA,color:#581C87,stroke-width:2px;
    classDef current fill:#E0F2FE,stroke:#0284C7,color:#0C4A6E,stroke-width:3px;
    classDef done fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:2px;
    classDef future fill:#F3F4F6,stroke:#6B7280,color:#374151,stroke-width:2px,stroke-dasharray:5 5;
```

## Identidade documental e física

Os nomes dos laboratórios registram a história de implementação. O nome do schema representa a localização física atual dos dados:

```text
DOC 01 ↔ A1 ↔ Evidences/LAB_A1
DOC 02 ↔ A2 ↔ Evidences/LAB_A2
DOC 03 ↔ A3 ↔ Evidences/LAB_A3
Schema físico compartilhado ↔ INDUSTRIAL_DATA
```

Portanto, referências históricas a `LAB_A1` não devem ser substituídas globalmente por `INDUSTRIAL_DATA`. O primeiro identifica o laboratório e suas evidências; o segundo identifica o schema físico ativo.

## Fundação A1 preservada

A migration preservou integralmente os dados e relacionamentos construídos no cenário A1:

| Entidade | Registros |
|---|---:|
| `PLANT` | 20 |
| `MATERIAL` | 300 |
| `STORAGE_LOCATION` | 152 |
| `MATERIAL_PLANT` | 1.080 |
| `MATERIAL_STORAGE_LOCATION` | 2.163 |
| **Total do A1** | **3.715** |

Os resultados permaneceram coerentes após a mudança de schema:

- Primary Keys duplicadas: `0`;
- Foreign Keys órfãs: `0`;
- cinco tabelas Foundation preservadas;
- cinco Foreign Keys Foundation aplicadas e validadas;
- 3.715 registros preservados.

## A2 · Estrutura Organizacional materializada e validada

O cenário A2 adicionou a hierarquia legal e a estrutura de compras necessárias para conectar a fundação de dados aos futuros processos transacionais.

```mermaid
flowchart TB
    C["COMPANY<br/>Grupo corporativo"]:::corporate
    CC["COMPANY_CODE<br/>Entidade legal"]:::legal
    P["PLANT<br/>Unidade operacional<br/>BUKRS NOT NULL"]:::plant
    S["STORAGE_LOCATION<br/>Subdivisão de estoque"]:::storage
    PO["PURCHASING_ORGANIZATION<br/>Autoridade de compras"]:::purchasing
    PPO["PLANT_PURCHASING_ORG<br/>Associação organizacional"]:::association
    PG["PURCHASING_GROUP<br/>Responsabilidade do comprador"]:::purchasing
    C -->|"1:N"| CC
    CC -->|"1:N · BUKRS"| P
    P -->|"1:N · WERKS"| S
    P -->|"1:N"| PPO
    PO -->|"1:N"| PPO
    PO -.->|"colaboração operacional"| PG
    classDef corporate fill:#E8F1FF,stroke:#2563EB,color:#123A70,stroke-width:2px;
    classDef legal fill:#FFF3D8,stroke:#F59E0B,color:#8A4B00,stroke-width:2px;
    classDef plant fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:2px;
    classDef storage fill:#E0F2FE,stroke:#0284C7,color:#0C4A6E,stroke-width:2px;
    classDef purchasing fill:#F3E8FF,stroke:#9333EA,color:#581C87,stroke-width:2px;
    classDef association fill:#FFF1F2,stroke:#E11D48,color:#881337,stroke-width:2px;
```

Os identificadores físicos das entidades permanecem em inglês e em letras maiúsculas porque correspondem aos nomes reais das tabelas no SAP HANA Cloud. As descrições funcionais do diagrama foram traduzidas para facilitar a compreensão do público brasileiro.

### Resultado consolidado

| Controle | Resultado |
|---|---:|
| Company | 1 |
| Company Codes | 4 |
| Plants atualizados | 20 |
| Purchasing Organizations | 5 |
| Purchasing Groups | 12 |
| Associações Plant × Purchasing Organization | 33 |
| Novos registros do A2 | 55 |
| Registros Foundation preservados | 3.715 |
| Total de registros no schema | 3.770 |
| Tabelas | 10 |
| Foreign Keys lógicas | 10 |
| Foreign Keys aplicadas | 10 |
| Foreign Keys validadas | 10 |
| Regras finais com status `PASSED` | 20 |
| Evidências físicas | 18 |

### Company Codes

Os quatro Company Codes representam entidades legais brasileiras fictícias. Todos utilizam `BRL` como moeda local:

| BUKRS | Nome | País | Moeda | Perfil | Plants |
|---|---|---|---|---|---:|
| `FBR1` | Industrial Manufacturing Brazil | `BRA` | `BRL` | Manufatura | 9 |
| `FBR2` | Components Manufacturing Brazil | `BRA` | `BRL` | Componentes | 2 |
| `FBR3` | Logistics and Distribution Brazil | `BRA` | `BRL` | Logística | 6 |
| `FBR4` | Engineering and Services Brazil | `BRA` | `BRL` | Engenharia e serviços | 3 |

Os nomes mestres continuam em inglês porque representam valores efetivamente carregados nas tabelas e poderão ser consumidos por aplicações, APIs e relatórios bilíngues.

### Evolução controlada de `PLANT`

A tabela `PLANT`, previamente criada e carregada no A1, foi evoluída sem recriação ou perda de registros:

1. a coluna `BUKRS NVARCHAR(4)` foi adicionada temporariamente como nullable;
2. os 20 Plants foram associados aos quatro Company Codes;
3. a ausência de valores nulos e desconhecidos foi validada;
4. a coluna `BUKRS` foi alterada para `NOT NULL`;
5. a constraint `FK_PLANT_COMPANY_CODE` foi criada;
6. a Foreign Key foi confirmada como aplicada e validada;
7. testes negativos demonstraram a rejeição de Company Codes inexistentes.

### Estrutura de compras

As Purchasing Organizations materializam a autoridade de compras, enquanto os Purchasing Groups representam responsabilidades por categorias de materiais, serviços ou investimentos.

- `P100`: Corporate Strategic Procurement, com escopo `CROSS_COMPANY_CODE`;
- `P110`: Manufacturing Procurement, associada primariamente ao `FBR1`;
- `P120`: Components Procurement, associada primariamente ao `FBR2`;
- `P130`: Logistics Procurement, associada primariamente ao `FBR3`;
- `P140`: Engineering and Services Procurement, associada primariamente ao `FBR4`;
- 20 associações do tipo `PRIMARY`;
- 13 associações do tipo `STRATEGIC_SUPPORT`;
- 33 associações válidas, sem registros órfãos ou duplicados.

A organização `P100` possui `PRIMARY_BUKRS = NULL` intencionalmente, pois representa uma autoridade corporativa transversal e não uma organização limitada a um único Company Code.

O A2 também preserva `PURCHASING_GROUP` sem uma Foreign Key obrigatória para uma única Purchasing Organization. Essa decisão evita impor uma cardinalidade artificial antes dos futuros cenários completos de procurement.

### Artefatos reproduzíveis

O cenário A2 foi preservado como um pacote reproduzível de scripts e validações:

```text
Industrial-Data-Universe/Datasets/Enterprise-Structure/
├── Load/          6 scripts SQL de carga e construção
├── Validation/    6 scripts SQL de validação
└── a2-enterprise-structure-sql-manifest.json
```

O manifest foi validado com:

```text
Scripts de carga:                 6
Scripts de validação:             6
Referências físicas no manifest: 12
Arquivos ausentes:                0
```

Os scripts da pasta `Load/` representam a reconstrução do cenário a partir do estado final do A1. Eles não devem ser reexecutados no ambiente atual porque os objetos e dados do A2 já estão materializados. Os scripts da pasta `Validation/` podem ser utilizados para auditoria e reconciliação.

## A3 · Dados Mestre de Material materializados e validados

O cenário A3 transformou as três tabelas planas de material do A1 em uma estrutura em camadas organizacionais no estilo SAP: visão client (MARA), descrições (MAKT), visão planta (MARC), avaliação (MBEW) e unidades alternativas (MARM). A integridade de domínio passou a ser dirigida por check tables e a visão planta foi amarrada à estrutura de compras do A2.

```mermaid
flowchart TB
    MT["Check tables<br/>MATERIAL_TYPE · MATERIAL_GROUP<br/>UNIT_OF_MEASURE · DIVISION · CURRENCY"]:::config
    MARA["MATERIAL (MARA)<br/>+ MBRSH · SPART · PRDHA · MSTAE · pesos"]:::client
    MAKT["MATERIAL_DESCRIPTION (MAKT)<br/>600 linhas · EN + PT"]:::client
    MARC["MATERIAL_PLANT (MARC)<br/>+ DISPO · EKGRP · MMSTA · PLIFZ · EISBE · MINBE"]:::plant
    MBEW["MATERIAL_VALUATION (MBEW)<br/>1080 linhas · moeda derivada"]:::valuation
    MARM["MATERIAL_UOM (MARM)<br/>574 linhas · UMREZ / UMREN"]:::plant
    PG["PURCHASING_GROUP (A2)"]:::a2
    CC["COMPANY_CODE.CURRENCY (A2)"]:::a2
    MT --> MARA
    MARA --> MAKT
    MARA --> MARC
    MARA --> MARM
    MARC --> MBEW
    MARC -->|"EKGRP FK"| PG
    MBEW -.->|"WAERS derivada"| CC
    classDef config fill:#EEF2FF,stroke:#6366F1,color:#312E81,stroke-width:2px;
    classDef client fill:#E7F8EC,stroke:#16A34A,color:#14532D,stroke-width:2px;
    classDef plant fill:#E0F2FE,stroke:#0284C7,color:#0C4A6E,stroke-width:2px;
    classDef valuation fill:#FFF3D8,stroke:#F59E0B,color:#8A4B00,stroke-width:2px;
    classDef a2 fill:#F3E8FF,stroke:#9333EA,color:#581C87,stroke-width:2px;
```

### Resultado consolidado

| Métrica | Valor |
|---|---:|
| Tabelas no schema | 18 |
| Foreign Keys lógicas | 22 |
| Registros totais A2 | 3.770 |
| Novos registros do A3 | 2.296 |
| Registros totais | 6.066 |
| Regras finais de reconciliação | 19 `PASSED` |
| Regras de integridade sem violação | 8 |
| Testes negativos consolidados | 5 |
| Evidências | 9 |

### Novas entidades

| Entidade | Referência SAP | Chave | Registros |
|---|---|---|---:|
| `MATERIAL_TYPE` | T134 / T134M | `MTART` | 4 |
| `MATERIAL_GROUP` | T023 / T023T | `MATKL` | 24 |
| `UNIT_OF_MEASURE` | T006 / T006A | `MSEHI` | 6 |
| `DIVISION` | TSPA / TSPAT | `SPART` | 5 |
| `CURRENCY` | TCURC | `WAERS` | 3 |
| `MATERIAL_DESCRIPTION` | MAKT | `MATNR + SPRAS` | 600 |
| `MATERIAL_VALUATION` | MBEW | `MATNR + BWKEY + BWTAR` | 1.080 |
| `MATERIAL_UOM` | MARM | `MATNR + MEINH` | 574 |

### Entidades evoluídas

- `MATERIAL` (MARA): sete atributos client-level e cinco Foreign Keys para as check tables.
- `MATERIAL_PLANT` (MARC): sete atributos de planejamento e compras, com `EKGRP` amarrado ao `PURCHASING_GROUP` do A2.
- `COMPANY_CODE`: `CURRENCY` passou a ser protegida por Foreign Key para a tabela `CURRENCY`.

### Decisões de modelagem

- **Área de avaliação = Plant** (padrão S/4): o mesmo material pode ter valor diferente em plantas diferentes.
- **`MATERIAL_TYPE` é a chave de controle**: define tipo de aquisição, controle de preço, classe de avaliação e atualização de quantidade/valor.
- **Moeda nunca é hard-coded**: `MATERIAL_VALUATION.WAERS` é derivada de `PLANT.BUKRS → COMPANY_CODE.CURRENCY`.
- **Grupo de compras só quando há aquisição externa**: `EKGRP` é obrigatório apenas para materiais com `PROCUREMENT_TYPE = 'F'`.
- **Faixas de numeração auditadas, não impostas**: os `MATNR` do A1 foram preservados; a conformidade com a faixa por tipo é uma regra de validação.

### Prontidão multimoeda

Toda avaliação está em `BRL` hoje. Os Plants `1200` (59 materiais avaliados) e `2800` (51 materiais avaliados) permanecem organizacionalmente prontos para o futuro cenário `BRL/USD` sem qualquer mudança de schema — a coluna de moeda já existe e é populada por derivação.

### Artefatos reproduzíveis

```text
Industrial-Data-Universe/Datasets/Material-Master/
├── Load/         # 7 scripts (config, client view, MAKT, MARC, MBEW, MARM)
├── Validation/   # 8 scripts (integridade, views, join, reconciliação)
└── a3-material-master-sql-manifest.json
```

Os scripts da pasta `Load/` reconstroem o A3 a partir do estado final do A2 e não devem ser reexecutados no ambiente atual. Os scripts da pasta `Validation/` são somente leitura e podem ser reexecutados a qualquer momento.

### Nota conhecida

`SYS.M_TABLES.RECORD_COUNT` é uma view de monitoramento e pode ficar defasada em relação ao delta storage. A reconciliação final conta linhas com `COUNT(*)`, nunca com metadado de monitoramento.

## Cenário futuro de conversão BRL ↔ USD

Os Plants `1200` e `2800` foram validados como organizacionalmente preparados para futuros documentos em `USD`, mantendo `BRL` como moeda local do Company Code.

```text
Plant principal:             2800 · Export Operations Plant
Plant complementar:          1200 · Electronic Components Plant
Moeda local:                 BRL
Moeda futura do documento:   USD
Tipo de taxa planejado:      M
Fonte futura das taxas:      dados sintéticos e versionados
Aplicação Fiori futura:      Multicurrency Procurement Monitor
```

A validação do A2 indicou apenas prontidão organizacional. O A3 materializou a tabela `CURRENCY` e a coluna de moeda derivada na avaliação. As tabelas de taxas de câmbio, validade temporal, fatores de conversão, valores documentais e valores convertidos ainda não foram implementadas.

A futura solução deverá preservar o valor e a moeda originais em `USD` e derivar o valor local em `BRL`. Antes da implementação, deverão ser revalidados o quotation method, os fatores, a precisão decimal e a regra de seleção da taxa por data.

## Materialização incremental

| Domínio | Momento | Situação |
|---|---|---|
| Foundation | A1 / DOC 01 | ✅ Materializado e validado |
| Estrutura Organizacional | A2 / DOC 02 | ✅ Materializado e validado |
| Dados Mestre de Material | A3 / DOC 03 | ✅ Materializado e validado |
| Fornecedores MM | A4–A6 | 🔄 Blueprint até validação |
| Dados mestres PP | A7 | 🔄 Blueprint até validação |
| Dados mestres QM | A6/A7 | 🔄 Blueprint até validação |
| Dados mestres WM | A8 | 🔄 Blueprint até validação |
| Dados mestres MES | A9 | 🔄 Blueprint até validação |
| Transações | Bloco E | 🔄 Aguardar dados mestres validados |
| Moedas e taxas de câmbio | `CURRENCY` no A3; taxas em futuro procurement/analytics | 🔄 Parcialmente materializado |
| Eventos | Bloco I | 🔄 Aguardar modelo transacional validado |

Os nomes dos objetos e módulos SAP permanecem em inglês quando representam termos técnicos, identificadores físicos ou domínios consolidados do projeto. Os textos explicativos e os estados foram traduzidos para português.

## Gates de qualidade

1. nenhuma Primary Key duplicada;
2. nenhuma Foreign Key órfã;
3. nenhum campo obrigatório vazio;
4. comprimentos compatíveis com o target SAP HANA Cloud;
5. migrations preservam objetos, constraints e registros;
6. todos os 20 Plants possuem um Company Code válido;
7. cada Plant possui exatamente uma associação de compras primária;
8. associações de compras não possuem Plants ou organizações órfãs;
9. manifest e caminhos físicos permanecem reconciliados;
10. a seed fixa reproduz a massa sintética;
11. testes negativos falham somente pelo motivo planejado;
12. cenários cambiais preservam a moeda e o valor originais.

## Próxima ação

O cenário A3 está concluído e documentado. Antes de abrir o próximo cenário do Bloco A, o README vivo do repositório deve ser relido para identificar as opções reais ainda pendentes e confirmar o nome físico do próximo DOC, da próxima pasta de evidências e dos artefatos a serem produzidos.
