const cds = require('@sap/cds')
require('./srv/rest')          // registra os endpoints REST (F5)
module.exports = cds.server
