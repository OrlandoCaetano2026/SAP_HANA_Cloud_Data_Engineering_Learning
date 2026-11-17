using ProcurementService as service from '../../srv/service';
using from '../materials/annotations-eligibility';

// ───────────────────────────────────────────────────────────────
// G2 — Supplier Eligibility Explorer
// Lista de fornecedores (com contadores) + Object Page com os materiais
// que o fornecedor pode ou não fornecer hoje, e o motivo de cada bloqueio.
// Textos {i18n>...}: app/eligibility/_i18n (EN padrão, PT).
// ───────────────────────────────────────────────────────────────

annotate service.Suppliers with {
  LIFNR             @Common.Label: '{i18n>supplier}'
                    @Common.ValueList: {
                      CollectionPath : 'Suppliers',
                      Parameters     : [
                        { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: LIFNR, ValueListProperty: 'LIFNR' },
                        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'LIFNR_TEXT' }
                      ]
                    };
  LIFNR_TEXT        @Common.Label: '{i18n>supplierName}';
  LIFNR_STATUS      @Common.Label: '{i18n>supplierStatus}'
                    @Common.ValueListWithFixedValues: true
                    @Common.ValueList: {
                      CollectionPath : 'SupplierStatuses',
                      Parameters     : [
                        { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: LIFNR_STATUS, ValueListProperty: 'CODE' },
                        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'TEXT' }
                      ]
                    };
  COUNTRY           @Common.Label: '{i18n>country}';
  CURRENCY          @Common.Label: '{i18n>currency}';
  PAYMENT_TERMS     @Common.Label: '{i18n>paymentTerms}';
  QUALITY_CERTIFIED @Common.Label: '{i18n>qualityCertified}';
  ITEMS_TOTAL       @Common.Label: '{i18n>itemsTotal}';
  ITEMS_ELIGIBLE    @Common.Label: '{i18n>itemsEligible}';
  ITEMS_BLOCKED     @Common.Label: '{i18n>itemsBlocked}';
};

// Filtros por material e por situação (caminho pela associação `eligibility`)
annotate service.SupplierEligibility with {
  MATNR  @Common.ValueList: {
           CollectionPath : 'Materials',
           Parameters     : [
             { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: MATNR, ValueListProperty: 'MATNR' },
             { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'MATNR_TEXT' }
           ]
         };
  REASON @Common.Label: '{i18n>eligibilityReason}'
         @Common.ValueListWithFixedValues: true
         @Common.ValueList: {
           CollectionPath : 'EligibilityReasons',
           Parameters     : [
             { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: REASON, ValueListProperty: 'CODE' },
             { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'TEXT' }
           ]
         };
};

annotate service.Suppliers with @(
  UI.HeaderInfo : {
    $Type          : 'UI.HeaderInfoType',
    TypeName       : '{i18n>supplierSingular}',
    TypeNamePlural : '{i18n>supplierPlural}',
    Title          : { $Type: 'UI.DataField', Value: LIFNR_TEXT },
    Description    : { $Type: 'UI.DataField', Value: LIFNR }
  },

  UI.SelectionFields : [
    LIFNR,
    LIFNR_STATUS,
    COUNTRY,
    eligibility.MATNR,
    eligibility.REASON
  ],

  // Lista: uma linha por fornecedor. Importance: High = aparece no celular.
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: LIFNR,          ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: LIFNR_TEXT,     ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: status.TEXT,    Label: '{i18n>supplierStatus}', Criticality: STATUS_CRIT, CriticalityRepresentation: #WithIcon, ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: ITEMS_BLOCKED,  Criticality: BLOCKED_CRIT, ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: ITEMS_ELIGIBLE, ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: ITEMS_TOTAL,    ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: COUNTRY,        ![@UI.Importance]: #Low },
    { $Type: 'UI.DataField', Value: PAYMENT_TERMS,  ![@UI.Importance]: #Low }
  ],

  UI.PresentationVariant : {
    $Type          : 'UI.PresentationVariantType',
    SortOrder      : [ { $Type: 'Common.SortOrderType', Property: ITEMS_BLOCKED, Descending: true } ],
    Visualizations : [ '@UI.LineItem' ]
  },

  // Cabeçalho da Object Page: três indicadores
  UI.DataPoint #Status : {
    $Type: 'UI.DataPointType', Value: status.TEXT, Title: '{i18n>supplierStatus}', Criticality: STATUS_CRIT
  },
  UI.DataPoint #Eligible : {
    $Type: 'UI.DataPointType', Value: ITEMS_ELIGIBLE, Title: '{i18n>itemsEligible}', Criticality: 3
  },
  UI.DataPoint #Blocked : {
    $Type: 'UI.DataPointType', Value: ITEMS_BLOCKED, Title: '{i18n>itemsBlocked}', Criticality: BLOCKED_CRIT
  },
  UI.HeaderFacets : [
    { $Type: 'UI.ReferenceFacet', ID: 'HStatus',   Target: '@UI.DataPoint#Status' },
    { $Type: 'UI.ReferenceFacet', ID: 'HEligible', Target: '@UI.DataPoint#Eligible' },
    { $Type: 'UI.ReferenceFacet', ID: 'HBlocked',  Target: '@UI.DataPoint#Blocked' }
  ],

  UI.FieldGroup #General : {
    $Type : 'UI.FieldGroupType',
    Data  : [
      { $Type: 'UI.DataField', Value: LIFNR },
      { $Type: 'UI.DataField', Value: LIFNR_TEXT },
      { $Type: 'UI.DataField', Value: status.TEXT, Label: '{i18n>supplierStatus}', Criticality: STATUS_CRIT },
      { $Type: 'UI.DataField', Value: COUNTRY },
      { $Type: 'UI.DataField', Value: CURRENCY },
      { $Type: 'UI.DataField', Value: PAYMENT_TERMS },
      { $Type: 'UI.DataField', Value: QUALITY_CERTIFIED }
    ]
  },

  UI.Facets : [
    { $Type: 'UI.ReferenceFacet', ID: 'General',   Label: '{i18n>supplierData}',   Target: '@UI.FieldGroup#General' },
    { $Type: 'UI.ReferenceFacet', ID: 'Materials', Label: '{i18n>materialsServed}', Target: 'eligibility/@UI.LineItem#BySupplier' }
  ]
);

// Tabela da Object Page: um item por material, com a situação e o motivo.
// O material é um link para o G1 (Material Master Explorer) via navegação entre apps.
annotate service.SupplierEligibility with @(
  UI.LineItem #BySupplier : [
    { $Type: 'UI.DataFieldWithIntentBasedNavigation', Value: MATNR, SemanticObject: 'Materials', Action: 'display', ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: MATNR_TEXT,     ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: REASON_TEXT,    Criticality: REASON_CRIT, CriticalityRepresentation: #WithIcon, ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: NET_PRICE,      ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: LEAD_TIME_DAYS, ![@UI.Importance]: #Low },
    { $Type: 'UI.DataField', Value: VALID_TO,       ![@UI.Importance]: #Low },
    { $Type: 'UI.DataField', Value: CERT_TYPE,      ![@UI.Importance]: #Low },
    { $Type: 'UI.DataField', Value: CERT_VALID_TO,  Criticality: CERT_CRIT, ![@UI.Importance]: #Medium },
    { $Type: 'UI.DataField', Value: BLOCK_REASON,   ![@UI.Importance]: #Low }
  ],
  // Bloqueados primeiro (REASON_CRIT 1 = erro), depois por material
  UI.PresentationVariant #BySupplier : {
    $Type          : 'UI.PresentationVariantType',
    SortOrder      : [ { $Type: 'Common.SortOrderType', Property: REASON_CRIT }, { $Type: 'Common.SortOrderType', Property: MATNR } ],
    Visualizations : [ '@UI.LineItem#BySupplier' ]
  }
);
