ClientTemplates = require '../../..'


tpl1 = new ClientTemplates(base: "tpl1/", out: "tpl1/1.js", pattern: "**")
tpl2 = new ClientTemplates(base: "tpl2/", out: "tpl2/2.js", extract: false)
tpl3 = new ClientTemplates(base: "tpl3/", out: "tpl3/3.js", concat: false)
tpl4 = new ClientTemplates(base: "tpl4/")

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [tpl3, tpl1, tpl2, tpl4]

  jade:
    pretty: true
