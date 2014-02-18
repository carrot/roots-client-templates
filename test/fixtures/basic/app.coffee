ClientTemplates = require '../../..'

tpl1 = new ClientTemplates(path: "tpl1/**", out: "tpl1/1.js")
tpl2 = new ClientTemplates(path: "tpl2/*", out: "tpl2/2.js", extract: false)
tpl3 = new ClientTemplates(path: "tpl3/*", out: "tpl3/3.js", concat: false)
tpl4 = new ClientTemplates(path: "tpl4/*")

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [tpl3, tpl1, tpl2, tpl4]

  jade:
    pretty: true
