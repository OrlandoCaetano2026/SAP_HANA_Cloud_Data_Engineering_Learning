const cds = require('@sap/cds')

// F7 — regras de negócio do serviço de compras
class ProcurementService extends cds.ApplicationService {
  init() {
    this.before(['CREATE', 'UPDATE'], 'PurchaseOrders', (req) => {
      const { LIFNR, CURRENCY, PO_DATE } = req.data
      if (!LIFNR) return req.error(400, 'LIFNR (fornecedor) é obrigatório')
      if (!['BRL', 'USD', 'EUR'].includes(CURRENCY)) return req.error(400, `moeda inválida: ${CURRENCY}`)
      if (PO_DATE && new Date(PO_DATE) > new Date()) return req.error(400, 'PO_DATE não pode ser futura')
    })
    return super.init()
  }
}
module.exports = ProcurementService
