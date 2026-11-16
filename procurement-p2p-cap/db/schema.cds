namespace p2p;

using { cuid, managed } from '@sap/cds/common';

// ───────────────────────────────────────────────────────────────
// Códigos e organização (somente leitura no app; origem: ERP)
// ───────────────────────────────────────────────────────────────
entity MaterialType   { key MTART : String(4);  MTART_TEXT : String(60); }
entity Plant          { key WERKS : String(4);  WERKS_TEXT : String(60); }
entity PurchasingOrg  { key EKORG : String(4);  EKORG_TEXT : String(60); }
entity SupplierStatus { key CODE  : String(10); TEXT : String(40); }

entity DocType {
  key CODE    : String(2);
      TEXT    : String(60);
      VIA_APP : Boolean;          // true = nasce no app e entra no ERP já liberado
}

entity EligibilityReason {
  key CODE        : String(20);
      TEXT        : localized String(80);   // texto traduzível (tabela .texts)
      CRITICALITY : Integer;      // 1 erro · 2 atenção · 3 sucesso
}

entity OrderStatus {
  key CODE        : String(15);
      TEXT        : String(60);
      CRITICALITY : Integer;      // 0 neutro · 1 erro · 2 atenção · 3 sucesso
}

// ───────────────────────────────────────────────────────────────
// Dados mestres (cópia somente leitura; códigos iguais ao INDUSTRIAL_DATA)
// ───────────────────────────────────────────────────────────────
entity Material {
  key MATNR      : String(40);
      MATNR_TEXT : String(100);
      MTART      : String(4);
      MATKL      : String(9);
      MEINS      : String(3);
      QM_ACTIVE  : Boolean;       // true = controle de aquisição por QM (exige QIR)
      type       : Association to MaterialType on type.MTART = MTART;
}

entity Supplier {
  key LIFNR             : String(10);
      LIFNR_TEXT        : String(80);
      LIFNR_STATUS      : String(10);
      COUNTRY           : String(3);
      CURRENCY          : String(3);
      PAYMENT_TERMS     : String(10);
      QUALITY_CERTIFIED : String(1);
      status            : Association to SupplierStatus on status.CODE = LIFNR_STATUS;
}

// ───────────────────────────────────────────────────────────────
// Info records
// PIR: versão estendida do PURCHASING_INFO_RECORD (acrescenta moeda,
//      validade e quantidade mínima, que não existem na tabela original)
// QIR: novo (não existe no INDUSTRIAL_DATA)
// ───────────────────────────────────────────────────────────────
entity PurchasingInfoRecord {
  key INFO_RECORD_ID : Integer;
      MATNR          : String(40);
      LIFNR          : String(10);
      EKORG          : String(4);
      NET_PRICE      : Decimal(15, 2);
      PRICE_UNIT     : Integer;
      CURRENCY       : String(3);
      VALID_FROM     : Date;
      VALID_TO       : Date;
      LEAD_TIME_DAYS : Integer;
      MIN_QTY        : Decimal(15, 2);
      material       : Association to Material on material.MATNR = MATNR;
      supplier       : Association to Supplier on supplier.LIFNR = LIFNR;
}

entity QualityInfoRecord {
  key QIR_ID          : Integer;
      MATNR           : String(40);
      LIFNR           : String(10);
      QIR_STATUS      : String(10);      // RELEASED | BLOCKED
      BLOCK_REASON    : String(200);
      CERT_TYPE       : String(30);
      CERT_NO         : String(30);
      CERT_VALID_FROM : Date;
      CERT_VALID_TO   : Date;
      material        : Association to Material on material.MATNR = MATNR;
      supplier        : Association to Supplier on supplier.LIFNR = LIFNR;
}

// ───────────────────────────────────────────────────────────────
// Pedido (origem no app) e regras de aprovação
// ───────────────────────────────────────────────────────────────
entity PurchaseOrder : cuid, managed {
  REQ_NO        : String(12);                       // número do app (ex.: ZF-000001)
  LIFNR         : String(10);
  EKORG         : String(4);
  DOC_TYPE      : String(2)  default 'ZF';
  STATUS        : String(15) default 'NEW';
  CURRENCY      : String(3)  default 'BRL';
  PO_DATE       : Date;
  TOTAL_AMOUNT  : Decimal(15, 2);                   // calculado a partir dos itens
  REJECT_REASON : String(300);
  EXTERNAL_REF  : String(40);                       // chave de idempotência da integração
  ERP_EBELN     : String(10);                       // número devolvido pelo ERP
  ERP_MESSAGE   : String(300);                      // mensagem de erro do ERP, se houver
  APPROVED_BY   : String(60);
  APPROVED_AT   : Timestamp;
  supplier      : Association to Supplier    on supplier.LIFNR = LIFNR;
  purchOrg      : Association to PurchasingOrg on purchOrg.EKORG = EKORG;
  docType       : Association to DocType     on docType.CODE = DOC_TYPE;
  orderStatus   : Association to OrderStatus on orderStatus.CODE = STATUS;
  items         : Composition of many PurchaseOrderItem on items.order = $self;
}

entity PurchaseOrderItem : cuid {
  order         : Association to PurchaseOrder;
  ITEM_NO       : Integer;
  MATNR         : String(40);
  WERKS         : String(4);
  QUANTITY      : Decimal(15, 2);
  NET_PRICE     : Decimal(15, 2);
  AMOUNT        : Decimal(15, 2);                   // QUANTITY × NET_PRICE
  DELIVERY_DATE : Date;
  material      : Association to Material on material.MATNR = MATNR;
  plant         : Association to Plant    on plant.WERKS = WERKS;
}

entity ApprovalRule {
  key RULE_ID       : Integer;
      DOC_TYPE      : String(2);
      CURRENCY      : String(3);
      VALUE_FROM    : Decimal(15, 2);               // inclusivo
      VALUE_TO      : Decimal(15, 2);               // exclusivo
      APPROVER_ROLE : String(20);                   // Approver | ApproverSenior
      TOLERANCE_PCT : Decimal(5, 2);                // alteração até X% não exige nova aprovação
}

entity ApprovalLog : cuid {
  order   : Association to PurchaseOrder;
  EVENT   : String(20);                             // SUBMITTED | APPROVED | REJECTED | SENT | ERP_ERROR | CANCELLED
  BY_USER : String(60);
  AT_TIME : Timestamp;
  NOTE    : String(300);
  RULE_ID : Integer;
}
