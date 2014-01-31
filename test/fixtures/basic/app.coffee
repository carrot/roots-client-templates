ClientTemplates = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [new ClientTemplates(path: "templates/*.jade", out: "js/templates.js")]

  jade:
    pretty: true
