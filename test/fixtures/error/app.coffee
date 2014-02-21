ClientTemplates = require '../../..'


tpl1 = ClientTemplates(out: "tpl1/1.js")

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [tpl1]

  jade:
    pretty: true
