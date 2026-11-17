using p2p as db from '../db/schema';

// Papéis: Viewer (leitura) · Buyer (cria pedidos) · Approver / ApproverSenior (aprovam por alçada)
service ProcurementService @(path: '/odata/v4/p2p') @(requires: 'authenticated-user') {

  // ── Dados mestres e códigos: somente leitura ──
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior']
  entity Materials as select from db.Material
    mixin { eligibility : Association to many SupplierEligibility on eligibility.MATNR = $projection.MATNR; }
    into  { *, eligibility };
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity MaterialTypes     as projection on db.MaterialType;
  // Fornecedores (G2): associação com a elegibilidade + contadores por situação (para a lista e o cabeçalho da Object Page)
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior']
  entity Suppliers as select from db.Supplier as s
    mixin { eligibility : Association to many SupplierEligibility on eligibility.LIFNR = $projection.LIFNR; }
    into  {
      key s.LIFNR, s.LIFNR_TEXT, s.LIFNR_STATUS, s.COUNTRY, s.CURRENCY, s.PAYMENT_TERMS, s.QUALITY_CERTIFIED,
      s.status,
      eligibility,
      (select count(*) from SupplierEligibility as x where x.LIFNR = s.LIFNR)                           as ITEMS_TOTAL    : Integer,
      (select count(*) from SupplierEligibility as x where x.LIFNR = s.LIFNR and x.REASON =  'ELIGIBLE') as ITEMS_ELIGIBLE : Integer,
      (select count(*) from SupplierEligibility as x where x.LIFNR = s.LIFNR and x.REASON <> 'ELIGIBLE') as ITEMS_BLOCKED  : Integer,
      case when s.LIFNR_STATUS = 'ACTIVE' then 3 else 1 end                                              as STATUS_CRIT   : Integer,
      case when exists (select 1 from SupplierEligibility as x where x.LIFNR = s.LIFNR and x.REASON <> 'ELIGIBLE')
           then 1 else 3 end                                                                             as BLOCKED_CRIT  : Integer
    };
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity SupplierStatuses  as projection on db.SupplierStatus;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity Plants            as projection on db.Plant;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity PurchasingOrgs    as projection on db.PurchasingOrg;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity DocTypes          as projection on db.DocType;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity OrderStatuses     as projection on db.OrderStatus;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity PurchasingInfoRecords as projection on db.PurchasingInfoRecord;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity QualityInfoRecords    as projection on db.QualityInfoRecord;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity ApprovalRules     as projection on db.ApprovalRule;
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity ApprovalLogs      as projection on db.ApprovalLog;

  // ── Elegibilidade (G2): PIR válido + fornecedor ativo + QIR liberado com certificado válido ──
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior'] entity EligibilityReasons as projection on db.EligibilityReason;

  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior']
  entity EligibilityBase as select from db.PurchasingInfoRecord as p
    left join db.QualityInfoRecord as q on q.MATNR = p.MATNR and q.LIFNR = p.LIFNR
    left join db.Supplier          as s on s.LIFNR = p.LIFNR
    left join db.Material          as m on m.MATNR = p.MATNR
  {
    key p.INFO_RECORD_ID,
        p.MATNR, m.MATNR_TEXT, m.QM_ACTIVE,
        p.LIFNR, s.LIFNR_TEXT, s.LIFNR_STATUS,
        p.EKORG, p.NET_PRICE, p.PRICE_UNIT, p.CURRENCY,
        p.LEAD_TIME_DAYS, p.MIN_QTY, p.VALID_FROM, p.VALID_TO,
        q.QIR_STATUS, q.CERT_TYPE, q.CERT_NO, q.CERT_VALID_TO, q.BLOCK_REASON,
        days_between(cast($now as Date), q.CERT_VALID_TO) as DAYS_TO_EXPIRY : Integer,
        case
          when s.LIFNR_STATUS <> 'ACTIVE'                                   then 'SUPPLIER_NOT_ACTIVE'
          when p.VALID_TO   < cast($now as Date)                            then 'PIR_EXPIRED'
          when p.VALID_FROM > cast($now as Date)                            then 'PIR_NOT_YET_VALID'
          when m.QM_ACTIVE = true and q.QIR_ID is null                      then 'QIR_MISSING'
          when q.QIR_STATUS = 'BLOCKED'                                     then 'QIR_BLOCKED'
          when q.CERT_VALID_TO < cast($now as Date)                         then 'CERT_EXPIRED'
          else 'ELIGIBLE'
        end as REASON : String(20)
  };

  // Visão final: acrescenta o texto e a criticidade do motivo, e a criticidade do prazo do certificado
  @readonly @requires: ['Viewer','Buyer','Approver','ApproverSenior']
  entity SupplierEligibility as select from EligibilityBase as e
    left join db.EligibilityReason       as r on r.CODE = e.REASON
    left join db.EligibilityReason.texts as t on t.CODE = e.REASON and t.locale = $user.locale
  {
    key e.INFO_RECORD_ID,
        e.MATNR, e.MATNR_TEXT, e.QM_ACTIVE,
        e.LIFNR, e.LIFNR_TEXT, e.LIFNR_STATUS,
        e.EKORG, e.NET_PRICE, e.PRICE_UNIT, e.CURRENCY,
        e.LEAD_TIME_DAYS, e.MIN_QTY, e.VALID_FROM, e.VALID_TO,
        e.QIR_STATUS, e.CERT_TYPE, e.CERT_NO, e.CERT_VALID_TO, e.BLOCK_REASON,
        e.DAYS_TO_EXPIRY,
        e.REASON,
        coalesce(t.TEXT, r.TEXT) as REASON_TEXT : String(80),   // texto no idioma do usuário (cai no padrão)
        r.CRITICALITY            as REASON_CRIT : Integer,
        case
          when e.DAYS_TO_EXPIRY is null then 0
          when e.DAYS_TO_EXPIRY < 0     then 1
          when e.DAYS_TO_EXPIRY <= 90   then 2
          else 3
        end as CERT_CRIT : Integer
  };

  // ── Pedido (rascunho + itens) ──
  @odata.draft.enabled
  @restrict: [
    { grant: ['READ'],                       to: ['Viewer','Buyer','Approver','ApproverSenior'] },
    { grant: ['CREATE','UPDATE','DELETE'],   to: 'Buyer' }
  ]
  entity PurchaseOrders as projection on db.PurchaseOrder;

  @restrict: [
    { grant: ['READ'],                       to: ['Viewer','Buyer','Approver','ApproverSenior'] },
    { grant: ['CREATE','UPDATE','DELETE'],   to: 'Buyer' }
  ]
  entity PurchaseOrderItems as projection on db.PurchaseOrderItem;
}
