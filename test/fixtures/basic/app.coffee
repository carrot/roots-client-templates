ClientTemplates = require '../../..'


tpl1 = ClientTemplates(base: "tpl1/", out: "tpl1/1.js", pattern: "**")
tpl2 = ClientTemplates(base: "tpl2/", out: "tpl2/2.js", extract: false)
tpl3 = ClientTemplates(base: "tpl3/", out: "tpl3/3.js", concat: false)
tpl4 = ClientTemplates(base: "tpl4/")

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [tpl3, tpl1, tpl2, tpl4]

  jade:
    pretty: true
