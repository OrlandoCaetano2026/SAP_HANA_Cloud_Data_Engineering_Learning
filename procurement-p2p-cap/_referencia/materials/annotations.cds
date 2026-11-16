using ProcurementService as service from '../../srv/service';

// ───────────────────────────────────────────────────────────────
// G1 — Material Master Explorer (List Report + Object Page)
// ───────────────────────────────────────────────────────────────
annotate service.MaterialTypes with { MTART @title: 'Tipo'; MTART_TEXT @title: 'Descrição do tipo'; };

annotate service.Materials with {
  MATNR      @title: 'Material';
  MATNR_TEXT @title: 'Descrição';
  MTART      @title: 'Tipo de material'
             @Common.Text            : type.MTART_TEXT
             @Common.TextArrangement : #TextFirst
             @Common.ValueListWithFixedValues
             @Common.ValueList : {
               CollectionPath : 'MaterialTypes',
               Parameters     : [
                 { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: MTART, ValueListProperty: 'MTART' },
                 { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'MTART_TEXT' }
               ]
             };
  MATKL      @title: 'Grupo de mercadoria';
  MEINS      @title: 'Unidade';
  QM_ACTIVE  @title: 'Controle de qualidade (QM)';
};

annotate service.Materials with @(
  UI.HeaderInfo : {
    TypeName       : 'Material',
    TypeNamePlural : 'Materiais',
    Title          : { Value: MATNR },
    Description    : { Value: MATNR_TEXT }
  },

  UI.SelectionFields : [ MATNR, MTART, MATKL, QM_ACTIVE ],

  UI.LineItem : [
    { Value: MATNR },
    { Value: MATNR_TEXT },
    { Value: MTART },
    { Value: MATKL },
    { Value: MEINS },
    { Value: QM_ACTIVE }
  ],

  UI.FieldGroup #General : {
    Data : [
      { Value: MATNR },
      { Value: MATNR_TEXT },
      { Value: MTART },
      { Value: MATKL },
      { Value: MEINS },
      { Value: QM_ACTIVE }
    ]
  },

  UI.Facets : [
    { $Type: 'UI.ReferenceFacet', ID: 'General',     Label: 'Dados gerais',                         Target: '@UI.FieldGroup#General' },
    { $Type: 'UI.ReferenceFacet', ID: 'Suppliers',   Label: 'Fornecedores e elegibilidade (PIR + QIR)', Target: 'eligibility/@UI.LineItem#ByMaterial' }
  ]
);
