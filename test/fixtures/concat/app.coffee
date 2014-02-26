ClientTemplates = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [ClientTemplates(base: "tpl/", out: "tpl/helper.js", concat: false)]

  jade:
    pretty: true
