# C1 a C10: Ambiente Profissional SAP HANA e Segurança HDI

**🌐 Idioma / Language:** 🇧🇷 **Português** | [🇺🇸 English](../EN/01-c1-c10-professional-environment-and-hdi-security.en.md)

[⬆️ Voltar ao README](../../../README.md)

> **Status:** ✅ Concluído (C1, C2, C3, C4, C6, C7, C8) · ⚠️ Bloqueado por limitação de plataforma, documentado (C5, C9) · 🔜 Consolidado via lições vividas (C10) · Pendente para sessão futura: **C11 — CAP & Modern CDS**
> **Ambiente:** SAP Business Application Studio (BAS) · SAP HANA Cloud Trial · Cloud Foundry (`hdi-shared` plan)
> **Classificação:** ambiente de desenvolvimento educacional, sem dados de produção

## 🎯 Visão executiva

Depois de 10 blocos praticando SQL direto no console (Bloco B), esse documento marca a virada de chave para o **fluxo profissional de desenvolvimento SAP HANA**: projeto versionável, HDI Container, deploy automatizado via Cloud Foundry, e — o ponto mais valioso deste bloco — uma investigação real e extensa sobre **segurança de HDI Container**, motivada não por planejamento, mas por uma sequência de erros genuínos que se tornaram o próprio conteúdo do C10.

Diferente do Bloco A (dados determinísticos, sem surpresas) e do Bloco B (SQL puro, ambiente sempre acessível), o Bloco C aconteceu em um ambiente **real de nuvem**, com todas as suas imperfeições: erros de sintaxe descobertos por tentativa e erro, uma feature da plataforma descontinuada no meio do caminho, e uma limitação de rede que impediu a validação final de um dos cenários. Cada um desses obstáculos foi documentado como está — inclusive o que **não** foi resolvido — porque isso também é aprendizado real de engenharia.

| Cenário | Objetivo | Resultado |
|---|---|---|
| C1 | Business Application Studio | ✅ Dev Space `SAP HANA Native Application` criado e operacional |
| C2 | HANA Database Project | ✅ Projeto `industrial_data_db` criado, estrutura `db/src` gerada |
| C3 | HDI Container | ✅ Container vinculado via `mta.yaml` (`resources.hdi_db`) |
| C4 | Design-Time Artifacts | ✅ `material.hdbtable` criado e versionado |
| C5 | CDS Database Artifacts | ⚠️ Bloqueado — CDS clássico (`.hdbcds`) descontinuado no HANA Cloud |
| C6 | Deployment | ✅ Build (`mbt build`) + Deploy (`cf deploy`) bem-sucedidos |
| C7 | Runtime Objects | ✅ Objetos validados via metadados (`SYS.TABLES`, `SYS.TABLE_COLUMNS`) |
| C8 | Synonyms & Cross-Schema Access | ✅ `CREATE SYNONYM` testado e validado com dados reais (300 linhas) |
| C9 | Calculation Views | ⚠️ Parcial — conceito modelado, dado real provado via SQL equivalente; editor gráfico bloqueado por rede |
| C10 | Security & Privileges | ✅ Consolidado — vivido na prática ao longo de todo o bloco |
| C11 | CAP & Modern CDS (`@sap/cds-dk`) | ⏳ Pendente — sucessor do CDS clássico descontinuado no C5, a praticar em sessão futura |

> [!IMPORTANT]
> Nenhuma credencial real permanece ativa após este documento. A service key criada para testes (`my-dev-key`, `my-dev-key-2`) foi removida com `cf delete-service-key`. Senhas que apareceram nos logs de trabalho nunca foram persistidas em nenhum arquivo do repositório.

---

## 🧭 Storytelling funcional

### C1 — Preparando o ambiente profissional

O primeiro obstáculo já apareceu na criação do Dev Space: o SAP BTP Trial tem **dois landscapes diferentes** dentro da mesma região US10 — o endpoint do Cloud Foundry usado pelo wizard gráfico (`api.cf.us10.hana.ondemand.com`) não era o mesmo do Org real da conta (`api.cf.us10-001.hana.ondemand.com`, visível em **BTP Cockpit → Cloud Foundry Environment**). Esse mismatch gerava o erro `There is no Org defined for this landscape` até o endpoint ser corrigido manualmente no login.

Dev Space criado como `SAP HANA Native Application`, com as extensões predefinidas (SAP HANA Tools, Database Explorer, Calculation View Editor, MTA Tools) já cobrindo o essencial do roteiro sem precisar ativar nada extra — só `CDS Graphical Modeler` foi adicionado manualmente.

### C2 + C3 — Projeto e HDI Container

O wizard **"New Project From Template" → "SAP HANA Database Project"** gerou a estrutura `db/src/` com `.hdiconfig` e `.hdinamespace`. O primeiro bloqueio real: o nome do Dev Space não aceita hífen (`industrial-data-hana` → `industrial_data_hana`), só letras, números e underscore.

A etapa de **"Bind to HDI Container Service"** falhou silenciosamente na primeira tentativa (erro `Cloud Foundry Org and Space are not set`) porque a sessão do wizard gráfico expirou entre passos. A correção definitiva foi autenticar via **terminal** (`cf login --sso`, `cf target -o ... -s ...`) antes de reabrir o wizard — uma sessão CLI persistente é mais confiável que o fluxo gráfico passo-a-passo para esse tipo de binding.

O `mta.yaml` gerado confirma o vínculo:

```yaml
resources:
- name: hdi_db
  type: com.sap.xs.hdi-container
  parameters:
    config:
      schema: INDUSTRIAL_DATA_HDI
  properties:
    hdi-container-name: ${service-name}
```

### C4 + C6 — Primeiro artefato e primeiro deploy

O `material.hdbtable` foi escrito e falhou no primeiro deploy com um erro de **namespace**:

```
Error: com.sap.hana.di.table: "material" has to be prefixed with the namespace "industrial.data.db"
```

Correção: todo objeto dentro de um projeto com namespace declarado precisa do prefixo completo no nome, usando `::` como separador — `"industrial.data.db::material"`, não `"material"`. Depois dessa correção, `mbt build` + `cf deploy` completaram com sucesso, criando a tabela real no schema `INDUSTRIAL_DATA_HDI`.

### C5 — A descoberta da descontinuação do CDS clássico

A tentativa de criar `supplier.hdbcds` revelou, em cascata, três erros progressivos:

1. `.hdiconfig` não reconhecia a extensão `hdbcds` — corrigido adicionando a entrada `"hdbcds": { "plugin_name": "com.sap.hana.di.cds" }`.
2. Depois de corrigido, o erro mudou para `Could not find the "com.sap.hana.di.cds" build plugin` — o **plugin em si não existe** no motor de deploy do HANA Cloud atual.

**Conclusão documentada:** a SAP descontinuou o suporte a CDS clássico (`.hdbcds`) dentro de HDI Container puro no HANA Cloud. O caminho oficial atual é **CAP** (`@sap/cds-dk`), com estrutura de projeto e ferramentas completamente diferentes — por isso esse tópico foi movido para um bloco futuro dedicado (**C11**), em vez de forçado dentro do C5.

### C6 (continuação) → C7 → a investigação de segurança

Depois do deploy bem-sucedido, a tentativa de **ler os dados** da tabela `material` revelou a limitação central deste bloco: nem o usuário `DBADMIN` (dono de todo o restante da instância), nem o usuário técnico runtime (`_RT`) do próprio container, nem o usuário design-time (`_DT`, dono real do objeto) conseguiram fazer `SELECT` na tabela recém-criada.

Foram testadas, em sequência, **8 abordagens diferentes**:

| # | Abordagem | Resultado |
|---|---|---|
| 1 | `SELECT` direto como `DBADMIN` | `insufficient privilege` |
| 2 | `GRANT SELECT ... TO DBADMIN` (self-grant) | `grantor and grantee are identical` |
| 3 | `.hdbgrants` com `"roles": ["object_owner_privilege"]` | `global roles are not supported in case of an HDI container service binding` |
| 4 | `.hdbgrants` com `schema_privileges` explícitos | `schema privileges are not supported in case of an HDI container service binding` |
| 5 | `GRANT SELECT ... TO <usuário _RT>` via `DBADMIN` | `insufficient privilege` |
| 6 | Conexão externa com credenciais `_RT` (service key) | Sem tabelas visíveis / autenticação instável |
| 7 | Conexão externa com credenciais `_DT` (dono do objeto) | `authentication failed` |
| 8 | Wizard gráfico **"Grant HDI container privileges"** | `Socket closed by peer` (falha de rede, 4x consecutivas) |

**Conclusão documentada:** o plano `hdi-shared` do SAP HANA Cloud Trial **não suporta** concessão de privilégio de schema para o `application_user` via `.hdbgrants` — restrição de plataforma, não erro de configuração. As falhas de rede na tentativa 8 (mesmo erro repetido em IPs de destino diferentes) sugerem também bloqueio de conexão direta ao host do banco a partir do componente SAP HANA Project Explorer nesse ambiente — possivelmente agravado pela rede corporativa/VPN usada durante a sessão.

A validação estrutural do C7 foi então feita via metadados (caminho que **sempre funcionou**, porque não depende de `SELECT` nos dados, só de leitura de catálogo):

```sql
SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME = 'INDUSTRIAL_DATA_HDI';
-- retorna: industrial.data.db::material

SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH, IS_NULLABLE
FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'INDUSTRIAL_DATA_HDI' AND TABLE_NAME = 'industrial.data.db::material';
-- retorna as 4 colunas exatamente como definidas no .hdbtable
```

### C8 — Synonyms, a prova de que o conceito funciona quando o acesso já existe

Para provar `CREATE SYNONYM` com dado real, o teste foi deslocado para o schema `INDUSTRIAL_DATA` (Bloco A/B), onde `DBADMIN` já é dono:

```sql
CREATE SYNONYM DBADMIN.MAT FOR INDUSTRIAL_DATA.MATERIAL;
SELECT * FROM DBADMIN.MAT;  -- 300 linhas, idêntico ao SELECT direto
```

**Lição chave:** Synonym é transparência de nomeação, não é mecanismo de bypass de segurança. Ele só funciona quando o privilégio subjacente já existe — confirmando, por caminho independente, o diagnóstico do C6/C7.

### C9 — Calculation View, conceito provado sem o editor gráfico

A busca de fontes de dados dentro do editor gráfico do Calculation View (`Find Data Sources`) retornou `No data` mesmo com o filtro "local objects" desativado — sintoma da mesma cadeia de acesso limitado. Em vez de insistir no editor visual, o conceito de **Aggregation → Semantics** (a estrutura central de uma Calculation View tipo CUBE) foi provado com uma query SQL equivalente, rodando sobre o Synonym validado no C8:

```sql
SELECT MTART AS TIPO_MATERIAL, MATKL AS GRUPO_MERCADORIA,
       COUNT(*) AS QTD_MATERIAIS, AVG(BRGEW) AS PESO_BRUTO_MEDIO, SUM(NTGEW) AS PESO_LIQUIDO_TOTAL
FROM DBADMIN.MAT
GROUP BY MTART, MATKL
ORDER BY QTD_MATERIAIS DESC;
-- 24 linhas de agregação real
```

### C10 — Security & Privileges, consolidado pela prática

Este cenário não teve um exercício isolado porque **foi vivido inteiro** ao longo do C6 ao C9. Os conceitos centrais, todos comprovados empiricamente:

- **Menor privilégio por padrão**: HDI Container nasce sem conceder nada além do necessário para o próprio dono (`_DT`) — nem o super-usuário da instância (`DBADMIN`) tem acesso automático.
- **Usuários técnicos do HDI**: todo container gera um par de usuários — `_DT` (design-time / dono dos objetos, usado durante deploy) e `_RT` (runtime / application, usado por apps consumindo o container).
- **`.hdbgrants` tem limites por plano de serviço**: `hdi-shared` (Trial) não aceita as formas mais comuns de concessão — isso não aparece documentado de forma óbvia, só na prática.
- **`GRANT` direto via SQL exige que o grantor já possua o privilégio** — mesmo um usuário administrativo amplo como `DBADMIN` não pode conceder o que não tem.
- **Synonym não contorna segurança** — é uma camada de nomeação sobre um acesso que já precisa existir.

---

## 🗂️ Estrutura do projeto gerado

```text
industrial_data_db/
├── db/
│   ├── src/
│   │   ├── .hdiconfig              # plugins de build reconhecidos (editado: +hdbcds)
│   │   ├── .hdinamespace           # define o namespace industrial.data.db
│   │   ├── material.hdbtable       # tabela deployada com sucesso
│   │   ├── supplier.hdbcds         # bloqueado (CDS clássico descontinuado)
│   │   ├── material_summary.hdbcalculationview  # conceito modelado, não populado
│   │   └── industrial-data-db.hdbgrants          # tentativas de grant (não suportadas no plano)
│   └── package.json
└── mta.yaml                        # descritor MTA + binding do HDI Container
```

---

## 📸 Evidências

| Evidência | Cenário | Conteúdo |
|---|---|---|
| `C1-EV01` a `C1-EV04` | C1 | Configuração, status `RUNNING` e IDE carregada do Dev Space |
| `C2-EV01` | C2/C3 | `mta.yaml` com o binding do HDI Container confirmado |
| `C4-EV01` | C4 | `material.hdbtable` criado e salvo |
| `C6-EV01` | C6 | `mbt build` concluído com sucesso |
| `C6-EV02` | C6 | `cf deploy` concluído com sucesso (`Process finished`) |
| `C6-EV03` | C6/C7 | Metadados das 4 colunas confirmados via `SYS.TABLE_COLUMNS` |
| `C9-EV01` | C9 | Agregação real (24 linhas) provando o conceito de Calculation View via SQL |

Arquivos completos em [`Evidences/LAB_C/`](../../../Evidences/LAB_C/).

---

## 🔜 Próximos passos

- **C11 — CAP & Modern CDS (`@sap/cds-dk`)**: bloco novo, dedicado, para o sucessor oficial do CDS clássico — estrutura de projeto CAP, `srv/` + `db/`, deploy via `cds deploy`/`cds build`.
- **Revalidação do C9 (Calculation View gráfico) e do acesso de dados (C6/C7)** em rede doméstica, para isolar se a causa raiz era a VPN corporativa usada durante esta sessão.

---

[⬆️ Voltar ao README](../../../README.md)
