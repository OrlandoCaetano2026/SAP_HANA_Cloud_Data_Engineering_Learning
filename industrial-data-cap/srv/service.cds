using industrial.data as db from '../db/schema';

// F9 — autorização por papel, aplicada em cada entidade
// Viewer: somente leitura · Buyer: leitura + criar/alterar/apagar
service ProcurementService @(path: '/odata/v4/procurement') @(requires: 'authenticated-user') {

  @(restrict: [
    { grant: ['READ'],                       to: ['Viewer', 'Buyer'] },
    { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'Buyer' }
  ])
  entity PurchaseOrders as projection on db.PurchaseOrder;

  @(restrict: [
    { grant: ['READ'],                       to: ['Viewer', 'Buyer'] },
    { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'Buyer' }
  ])
  entity Materials as projection on db.Material;

  @(restrict: [{ grant: 'READ', to: ['Viewer', 'Buyer'] }])
  entity BrlOrders as select from db.PurchaseOrder {
    key EBELN as Pedido,
        LIFNR as Fornecedor,
        PO_DATE as Data
  } where CURRENCY = 'BRL';
}
