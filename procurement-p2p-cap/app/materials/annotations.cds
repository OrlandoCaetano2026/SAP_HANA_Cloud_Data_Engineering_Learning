using ProcurementService as service from '../../srv/service';
annotate service.Materials with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : '{i18n>material}',
                Value : MATNR,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>description}',
                Value : MATNR_TEXT,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>materialType}',
                Value : MTART,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>materialGroup}',
                Value : MATKL,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>baseUnit}',
                Value : MEINS,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>qmActive}',
                Value : QM_ACTIVE,
            },
        ],
    },
    UI.HeaderInfo : {
        $Type : 'UI.HeaderInfoType',
        TypeName : '{i18n>materialSingular}',
        TypeNamePlural : '{i18n>materialPlural}',
        Title : {
            $Type : 'UI.DataField',
            Value : MATNR_TEXT,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : MATNR,
        },
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : '{i18n>materialData}',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'EligibleSuppliers',
            Label : '{i18n>eligibleSuppliers}',
            Target : 'eligibility/@UI.LineItem#ByMaterial',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : '{i18n>material}',
            Value : MATNR,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>description}',
            Value : MATNR_TEXT,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>materialType}',
            Value : MTART,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>materialGroup}',
            Value : MATKL,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>baseUnitShort}',
            Value : MEINS,
        },
        {
            $Type : 'UI.DataField',
            Value : QM_ACTIVE,
        },
    ],
    UI.SelectionFields : [
        MATNR,
        MTART,
        MATKL,
        QM_ACTIVE,
    ],
);

annotate service.Materials with {
    MATNR     @Common.Label : '{i18n>material}';
    MATNR_TEXT @Common.Label : '{i18n>description}';
    MTART     @Common.Label : '{i18n>materialType}';
    MATKL     @Common.Label : '{i18n>materialGroup}';
    MEINS     @Common.Label : '{i18n>baseUnit}';
    QM_ACTIVE @Common.Label : '{i18n>qmActive}';
};
