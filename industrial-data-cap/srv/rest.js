// F5 — REST simples (fora do padrão OData), exposto no mesmo servidor CAP
const cds = require('@sap/cds')

cds.on('bootstrap', (app) => {
  // GET /rest/materiais/resumo -> total e contagem por tipo de material
  app.get('/rest/materiais/resumo', async (req, res) => {
    const db = await cds.connect.to('db')
    const rows = await db.run(SELECT.from('industrial.data.Material'))
    const porTipo = {}
    for (const r of rows) porTipo[r.MTART] = (porTipo[r.MTART] || 0) + 1
    res.json({ total: rows.length, porTipo })
  })

  // GET /rest/materiais/:matnr -> um material, em formato REST próprio
  app.get('/rest/materiais/:matnr', async (req, res) => {
    const db = await cds.connect.to('db')
    const row = await db.run(SELECT.one.from('industrial.data.Material').where({ MATNR: req.params.matnr }))
    if (!row) return res.status(404).json({ erro: 'material nao encontrado', matnr: req.params.matnr })
    res.json({ codigo: row.MATNR, descricao: row.MATNR_TEXT, tipo: row.MTART })
  })
})
