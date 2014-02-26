ClientTemplates = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [ClientTemplates(base: "tpl/", out: "tpl/all.js", extract: false)]

  jade:
    pretty: true
