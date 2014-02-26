ClientTemplates = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [ClientTemplates(out: "tpl/all.js")]

  jade:
    pretty: true
