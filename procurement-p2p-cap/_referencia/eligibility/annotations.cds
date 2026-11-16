using ProcurementService as service from '../../srv/service';

// ───────────────────────────────────────────────────────────────
// G2 — Supplier Eligibility Explorer (PIR + QIR + status do fornecedor)
// ───────────────────────────────────────────────────────────────
annotate service.EligibilityReasons with { CODE @title: 'Código'; TEXT @title: 'Motivo'; };

annotate service.SupplierEligibility with {
  INFO_RECORD_ID @title: 'Info record';
  MATNR          @title: 'Material'
                 @Common.ValueList : {
                   CollectionPath : 'Materials',
                   Parameters     : [
                     { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: MATNR, ValueListProperty: 'MATNR' },
                     { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'MATNR_TEXT' }
                   ]
                 };
  MATNR_TEXT     @title: 'Descrição do material';
  QM_ACTIVE      @title: 'Material com controle QM';
  LIFNR          @title: 'Fornecedor'
                 @Common.ValueList : {
                   CollectionPath : 'Suppliers',
                   Parameters     : [
                     { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: LIFNR, ValueListProperty: 'LIFNR' },
                     { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'LIFNR_TEXT' }
                   ]
                 };
  LIFNR_TEXT     @title: 'Nome do fornecedor';
  LIFNR_STATUS   @title: 'Status do fornecedor';
  EKORG          @title: 'Org. de compras';
  NET_PRICE      @title: 'Preço líquido';
  PRICE_UNIT     @title: 'Unidade de preço';
  CURRENCY       @title: 'Moeda';
  LEAD_TIME_DAYS @title: 'Prazo de entrega (dias)';
  MIN_QTY        @title: 'Quantidade mínima';
  VALID_FROM     @title: 'PIR válido de';
  VALID_TO       @title: 'PIR válido até';
  QIR_STATUS     @title: 'Status do QIR';
  CERT_TYPE      @title: 'Tipo de certificado';
  CERT_NO        @title: 'Número do certificado';
  CERT_VALID_TO  @title: 'Certificado válido até';
  BLOCK_REASON   @title: 'Motivo do bloqueio';
  DAYS_TO_EXPIRY @title: 'Dias para vencer o certificado';
  REASON         @title: 'Motivo (código)'
                 @Common.ValueListWithFixedValues
                 @Common.ValueList : {
                   CollectionPath : 'EligibilityReasons',
                   Parameters     : [
                     { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: REASON, ValueListProperty: 'CODE' },
                     { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'TEXT' }
                   ]
                 };
  REASON_TEXT    @title: 'Situação';
};

annotate service.SupplierEligibility with @(
  UI.HeaderInfo : {
    TypeName       : 'Elegibilidade',
    TypeNamePlural : 'Elegibilidade de fornecedores',
    Title          : { Value: MATNR },
    Description    : { Value: LIFNR_TEXT }
  },

  UI.SelectionFields : [ MATNR, LIFNR, REASON, EKORG ],

  UI.LineItem : [
    { Value: MATNR },
    { Value: MATNR_TEXT },
    { Value: LIFNR },
    { Value: LIFNR_TEXT },
    { $Type: 'UI.DataField', Value: REASON_TEXT, Criticality: REASON_CRIT, CriticalityRepresentation: #WithIcon },
    { Value: NET_PRICE },
    { Value: CURRENCY },
    { Value: LEAD_TIME_DAYS },
    { $Type: 'UI.DataField', Value: CERT_VALID_TO, Criticality: CERT_CRIT },
    { Value: DAYS_TO_EXPIRY }
  ],

  // Tabela embutida na Object Page do material (G1)
  UI.LineItem #ByMaterial : [
    { Value: LIFNR },
    { Value: LIFNR_TEXT },
    { $Type: 'UI.DataField', Value: REASON_TEXT, Criticality: REASON_CRIT, CriticalityRepresentation: #WithIcon },
    { Value: NET_PRICE },
    { Value: CURRENCY },
    { Value: LEAD_TIME_DAYS },
    { $Type: 'UI.DataField', Value: CERT_VALID_TO, Criticality: CERT_CRIT },
    { Value: BLOCK_REASON }
  ],

  UI.FieldGroup #Status : {
    Data : [
      { $Type: 'UI.DataField', Value: REASON_TEXT, Criticality: REASON_CRIT, CriticalityRepresentation: #WithIcon },
      { Value: LIFNR_STATUS },
      { Value: QM_ACTIVE }
    ]
  },
  UI.FieldGroup #PIR : {
    Data : [
      { Value: EKORG }, { Value: NET_PRICE }, { Value: PRICE_UNIT }, { Value: CURRENCY },
      { Value: LEAD_TIME_DAYS }, { Value: MIN_QTY }, { Value: VALID_FROM }, { Value: VALID_TO }
    ]
  },
  UI.FieldGroup #QIR : {
    Data : [
      { Value: QIR_STATUS }, { Value: BLOCK_REASON }, { Value: CERT_TYPE }, { Value: CERT_NO },
      { $Type: 'UI.DataField', Value: CERT_VALID_TO, Criticality: CERT_CRIT }, { Value: DAYS_TO_EXPIRY }
    ]
  },

  UI.Facets : [
    { $Type: 'UI.ReferenceFacet', ID: 'Status', Label: 'Situação da elegibilidade',  Target: '@UI.FieldGroup#Status' },
    { $Type: 'UI.ReferenceFacet', ID: 'PIR',    Label: 'Info record de compras (PIR)', Target: '@UI.FieldGroup#PIR' },
    { $Type: 'UI.ReferenceFacet', ID: 'QIR',    Label: 'Info record de qualidade (QIR)', Target: '@UI.FieldGroup#QIR' }
  ]
);
