# B1 a B10: Fundamentos de SQL sobre Dados SAP

**🌐 Idioma / Language:** 🇧🇷 **Português** | [🇺🇸 English](../EN/01-b1-b10-sql-fundamentals-on-sap-data.en.md)

[⬆️ Voltar ao README](../../../README.md)

> **Status:** ✅ Concluído e validado
> **Schema físico:** `INDUSTRIAL_DATA` (mesmo dataset consolidado do Bloco A)
> **Ambiente:** SAP HANA Cloud Central → SQL Console
> **Classificação:** prática direta, sem gravação fotográfica de evidência — cada resultado foi validado interativamente e cruzado com contagens já conhecidas do Bloco A

## 🎯 Visão executiva

O Bloco B pega o dataset relacional inteiro construído no Bloco A (~7.848 registros, 39+ tabelas, ciclo completo procure-to-pay / order-to-cash / manufatura / qualidade / armazém) e usa ele como **campo de prática de SQL**, do fundamento (`WHERE`, `ORDER BY`) até tópicos avançados (Window Functions, SQLScript, EXPLAIN PLAN). A metodologia em cada exercício foi a mesma: **prever o resultado antes de rodar, executar, e validar cruzando com um número já conhecido de blocos anteriores** — nunca aceitar um resultado só porque "rodou sem erro".

Diferente do Bloco A e do Bloco C, este bloco não gerou evidências fotográficas formais (a prática foi 100% interativa, com resultado validado em tempo real na conversa). O valor deste documento é registrar **o quê** foi praticado, **quais armadilhas reais** apareceram, e **quais números de validação cruzada** confirmaram cada conceito — de forma que o exercício seja reprodutível.

| Bloco | Tópico | Conceitos centrais |
|---|---|---|
| B1 | Fundamentos | Estrutura de tabelas, exploração inicial do schema |
| B2 | DML | `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, autocommit |
| B3 | Filtering & Sorting | `WHERE`, `LIKE`, `BETWEEN`, `IN`, `NOT IN` + armadilha de NULL, `ORDER BY` + NULL |
| B4 | Joins | `INNER JOIN`, `LEFT JOIN`, cadeia de múltiplos JOINs, simplificação |
| B5 | Aggregations | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING` |
| B6 | Subqueries & CTEs | Subquery escalar, subquery correlacionada, `WITH` |
| B7 | Window Functions | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `PARTITION BY` |
| B8 | Views | `CREATE VIEW` simples e com `CASE WHEN` |
| B9 | SQLScript | Table Function parametrizada (`CREATE FUNCTION ... RETURNS TABLE`) |
| B10 | Performance | `EXPLAIN PLAN`, leitura de plano de execução |

---

## 🧭 Storytelling funcional

### B2 — DML e as duas armadilhas do ambiente Cloud

Dois comportamentos do HANA Cloud Trial surpreenderam a expectativa vinda de outros bancos:

- **Autocommit sem `ROLLBACK` útil**: o Cloud Central confirma cada statement imediatamente. Um `UPDATE` sem `WHERE` (erro intencional, para aprendizado) não pôde ser desfeito com `ROLLBACK` — em produção, a única saída real seria backup/PITR, indisponível no Free Tier. Isso não é bug, é a natureza do ambiente autocommit.
- **`TRUNCATE` não reseta `IDENTITY`**: diferente de MySQL/SQL Server, o HANA mantém a sequência do `IDENTITY` depois de um `TRUNCATE` — inserir depois de truncar continua a numeração de onde parou (ex: 3 → 4), não reinicia em 1.

### B3 — A armadilha do `NOT IN` com NULL

O exercício central deste bloco foi validar, passo a passo, uma cadeia de JOINs (`INSPECTION_LOT → GOODS_RECEIPT → PURCHASE_ORDER → SUPPLIER`) antes de confiar num resultado de `NOT IN`. A validação cruzada:

```sql
-- Total de fornecedores com histórico de inspeção
SELECT DISTINCT S.LIFNR FROM INSPECTION_LOT IL
JOIN GOODS_RECEIPT GR ON IL.GR_ID = GR.GR_ID
JOIN PURCHASE_ORDER S ON GR.EBELN = S.EBELN;
-- 25 fornecedores

-- NOT IN (fornecedores sem inspeção)
SELECT LIFNR FROM SUPPLIER WHERE LIFNR NOT IN (...);
-- 45 fornecedores → 70 total - 25 = 45 ✅ bate
```

Depois, a demonstração isolada do **NULL trap**:

```sql
SELECT LIFNR FROM SUPPLIER WHERE LIFNR NOT IN ('SUP-001', 'SUP-002', NULL);
-- 0 linhas — SEMPRE, para qualquer tabela
```

**Regra fixada:** se a subquery de um `NOT IN` pode retornar NULL na coluna selecionada, o resultado inteiro zera silenciosamente (comparação com NULL vira `UNKNOWN`, que quebra a cadeia de `AND`). A query original da cadeia de JOINs era segura porque `S.LIFNR` é FK `NOT NULL` — nunca have NULL ali, por isso não caiu na armadilha.

Também foi validado o comportamento de `ORDER BY` com NULL: **ASC → NULL primeiro; DESC → NULL por último** (padrão HANA, oposto ao padrão Oracle).

### B4 — Joins, do conceito à simplificação

`INNER JOIN` foi decomposto explicando a ordem real de execução (`FROM → JOIN/ON → WHERE → SELECT → ORDER BY → LIMIT`, nunca a ordem escrita). `LEFT JOIN + IS NULL` resolveu "fornecedores sem PO" (30 encontrados, validado contra `COUNT(DISTINCT LIFNR) = 40` com PO → `70 - 40 = 30` ✅).

Na cadeia de 4 tabelas (`SUPPLIER_INVOICE → GOODS_RECEIPT → PURCHASE_ORDER → SUPPLIER`), veio a lição de modelagem: como `SUPPLIER_INVOICE` já tem `LIFNR` redundante, o mesmo resultado sai com **1 JOIN** em vez de 3 — mas os dois caminhos têm significados diferentes (rastreabilidade documental completa vs. confiança no campo redundante).

### B5 — Agregações e a ordem WHERE → GROUP BY → HAVING

```sql
SELECT STATUS_CODE, COUNT(*) FROM PURCHASE_ORDER GROUP BY STATUS_CODE;
-- RELEASED 20 · OPEN 10 · CANCELLED 5 · CLOSED 5 → soma 40 ✅
```

A distinção prática entre `WHERE` (filtra antes de agrupar) e `HAVING` (filtra depois) foi fixada com um exemplo que combinava os dois na mesma query, cruzando o resultado com os totais já conhecidos do B4.

### B6 — Subqueries e CTE

Subquery escalar (`WHERE valor > (SELECT AVG(...))`), subquery correlacionada (demonstrando a diferença entre "linha externa não existe" vs. "existe mas sem match" — o primeiro caso a linha some, o segundo retorna NULL), e `WITH` reescrevendo a mesma lógica do B5.2 sem repetir o `GROUP BY`.

### B7 — Window Functions

`ROW_NUMBER() OVER (ORDER BY ...)` numerando as 25 notas fiscais sem perder nenhuma linha (diferente de `GROUP BY`, que colapsa). `PARTITION BY WERKS` reiniciando o ranking a cada planta (validado nas 20 plantas). A pegadinha clássica — **window function não pode ser filtrada no mesmo nível em que foi calculada** (`WHERE RANKING = 1` falha com `invalid column name`) — resolvida com CTE por fora. Por fim, `RANK` vs `DENSE_RANK` vs `ROW_NUMBER` comparados lado a lado num empate real (`UD_CODE`), mostrando que `RANK` pula números após o empate e `DENSE_RANK` não.

### B8 — Views

`CREATE VIEW` simples (resumo de faturamento por fornecedor) e uma view mais robusta com `CASE WHEN` classificando cada PO em situação de 3-way match (`FATURADO` / `RECEBIDO_SEM_FATURA` / `AGUARDANDO_RECEBIMENTO`), consultável com `GROUP BY` como se fosse tabela normal.

### B9 — SQLScript

Uma Table Function parametrizada resolveu, na prática, uma dúvida real sobre views "dinâmicas": diferente de uma `VIEW` (sempre fixa), uma function recebe parâmetro em cada chamada:

```sql
CREATE FUNCTION FN_PO_BY_STATUS(IN P_STATUS NVARCHAR(20))
RETURNS TABLE (...) LANGUAGE SQLSCRIPT AS
BEGIN RETURN SELECT ... WHERE PO.STATUS_CODE = :P_STATUS; END;

SELECT * FROM FN_PO_BY_STATUS('RELEASED');  -- 20 linhas
SELECT * FROM FN_PO_BY_STATUS('CANCELLED'); -- 5 linhas
```

Ambos os resultados batem exatamente com o `GROUP BY` do B5.1.

### B10 — Performance

`EXPLAIN PLAN` lido de baixo para cima: `TABLE SCAN` com `FILTER CONDITION` (predicate pushdown — filtro aplicado durante a leitura, não depois) seguido de `INDEX JOIN` (join via chave primária, não nested loop cego). Fechado com um resumo de boas práticas acumuladas ao longo do bloco inteiro (NOT IN vs NOT EXISTS, JOIN redundante, ordem WHERE/HAVING, window function + CTE).

---

## 📈 Números de validação cruzada usados no bloco

| Validação | Resultado |
|---|---:|
| Fornecedores com histórico de inspeção | 25 |
| Fornecedores sem inspeção (`NOT IN`) | 45 (70 − 25) |
| Fornecedores com pelo menos 1 PO | 40 |
| Fornecedores sem PO (`LEFT JOIN` + `IS NULL`) | 30 (70 − 40) |
| POs por status | RELEASED 20 · OPEN 10 · CANCELLED 5 · CLOSED 5 (soma 40) |
| POs `RELEASED` com mais de 5 itens | 5 (`PO-00039` com 11; 4× com 8) |
| Notas fiscais totais | 25 |
| Média geral de faturamento | 444.636,35 |
| Plantas com ranking reiniciado (`PARTITION BY`) | 20 |

---

[⬆️ Voltar ao README](../../../README.md)
