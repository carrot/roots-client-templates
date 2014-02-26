ClientTemplates = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [ClientTemplates(base: "tpl/")]

  jade:
    pretty: true
