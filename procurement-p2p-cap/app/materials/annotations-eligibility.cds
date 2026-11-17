using ProcurementService as service from '../../srv/service';
using from './annotations';


// ───────────────────────────────────────────────────────────────
// Elegibilidade de fornecedores (PIR + QIR + status do fornecedor)
// Usada pela tabela "Fornecedores elegíveis" da Object Page do material (G1)
// e pelo app próprio de elegibilidade (G2), na tabela #BySupplier (annotations do G2).
// ───────────────────────────────────────────────────────────────

annotate service.SupplierEligibility with {
  INFO_RECORD_ID @title: '{i18n>infoRecord}';
  MATNR          @title: '{i18n>material}';
  MATNR_TEXT     @title: '{i18n>materialDescription}';
  QM_ACTIVE      @title: '{i18n>qmControlled}';
  LIFNR          @title: '{i18n>supplier}';
  LIFNR_TEXT     @title: '{i18n>supplierName}';
  LIFNR_STATUS   @title: '{i18n>supplierStatus}';
  EKORG          @title: '{i18n>purchasingOrg}';
  NET_PRICE      @title: '{i18n>netPrice}'
                 @Measures.ISOCurrency: CURRENCY;
  PRICE_UNIT     @title: '{i18n>priceUnit}';
  CURRENCY       @title: '{i18n>currency}';
  LEAD_TIME_DAYS @title: '{i18n>leadTimeDays}';
  MIN_QTY        @title: '{i18n>minQty}';
  VALID_FROM     @title: '{i18n>pirValidFrom}';
  VALID_TO       @title: '{i18n>pirValidTo}';
  QIR_STATUS     @title: '{i18n>qirStatus}';
  CERT_TYPE      @title: '{i18n>certType}';
  CERT_NO        @title: '{i18n>certNo}';
  CERT_VALID_TO  @title: '{i18n>certValidTo}';
  BLOCK_REASON   @title: '{i18n>blockReason}';
  DAYS_TO_EXPIRY @title: '{i18n>daysToExpiry}';
  REASON         @title: '{i18n>reasonCode}';
  REASON_TEXT    @title: '{i18n>status}';
};

annotate service.SupplierEligibility with @(
  // Tabela embutida na Object Page do material.
  // REASON_CRIT (0-3) pinta a situação; CERT_CRIT pinta a validade do certificado.
  UI.LineItem #ByMaterial : [
    // Fornecedor = link para o G2 (Supplier Eligibility Explorer) via navegação entre apps
    { $Type: 'UI.DataFieldWithIntentBasedNavigation', Value: LIFNR, SemanticObject: 'Suppliers', Action: 'display', ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: LIFNR_TEXT,     ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: REASON_TEXT,    Criticality: REASON_CRIT, CriticalityRepresentation: #WithIcon, ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: NET_PRICE,      ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: LEAD_TIME_DAYS, ![@UI.Importance]: #Low },
    { $Type: 'UI.DataField', Value: CERT_VALID_TO,  Criticality: CERT_CRIT, ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: BLOCK_REASON,   ![@UI.Importance]: #Low }
  ]
);
