path      = require 'path'
fs        = require 'fs'
_         = require 'lodash'
W         = require 'when'
nodefn    = require 'when/node/function'
minimatch = require 'minimatch'
umd       = require 'umd'
uuid      = require 'node-uuid'
UglifyJS  = require("uglify-js");
mkdirp    = require 'mkdirp'

class ClientCompile

  constructor: (opts) ->
    @opts = _.defaults opts,
      out:      'js/templates.js'
      name:     'templates'
      pattern:  '**'
      concat:   true
      extract:  true
      compress: false
      category: "precompiled-#{uuid.v1()}" # uuid - multiple instances, no conflict

    {@extract, @concat, @category, @name, @out, @compress} = @opts

    if !@opts.base? then throw new Error('you must provide a base template path')
    @pattern = @opts.base + @opts.pattern

    @templates = {}

    # if you are concatenating, you can choose extract or not
    # if you are not concatenating, you must write the file
    @write = if @concat then !@extract else true

  fs: ->
    category: @category
    extract: @extract
    ordered: false
    detect: (f) => minimatch(f.relative, @pattern)

  compile_hooks: ->
    after_file: after_hook.bind(@)
    write: write_hook.bind(@)

  category_hooks: ->
    after: after_category.bind(@)

  # @api private

  after_hook = (ctx) ->
    if @category != ctx.category then return

    # last valid adapter is assumed to be your precompile target
    adapter = _.find(_.clone(ctx.adapters).reverse(), (a) -> a.name)

    # if this is the first template with this adapter, set up the store
    @templates[adapter.name] ?= { adapter: adapter, all: [] }

    # client-compile the file and add it to the store
    adapter.compileClient(ctx.content).then (out) =>
      # naming the template key

      # - remove roots root
      tpl_name = ctx.path.replace(ctx.roots.root,'')

      # - remove templates root
      tpl_name = tpl_name.split(@opts.base)[1]

      # - cut the file extension(s) and remove leading /
      tpl_name = tpl_name.split('.')[0]

      @templates[adapter.name].all.push(name: tpl_name, content: out)

      # if individual files wanted for templates, wrap & replace content
      if not @concat then ctx.content = umd(tpl_name, out)

      return @write

  write_hook = (ctx) ->
    # if out of category, don't write anything
    if @category != ctx.category then return false

    # if concat is true, write normal path. if false, write with a js extension
    if @concat
      { path: ctx.roots.config.out(ctx.path, _.last(ctx.adapters).output), content: ctx.content }
    else
      { path: ctx.roots.config.out(ctx.path, 'js'), content: ctx.content }

  after_category = (ctx, category) ->
    if @category != category then return

    tasks = []

    # for each category in templates
    for name, category of @templates
      output = ""

      # print client helpers to out file
      output += category.adapter.clientHelpers()

      # add templates to the exported object if necessary
      if @concat
        output += "return {"
        output += "\"#{tpl.name}\": #{tpl.content}," for tpl in category.all
        output = output.slice(0,-1)
        output += "};"

      # add umd wrapper
      output = umd(@name, output)

      if @compress then output = UglifyJS.minify(output, fromString: true).code

      # write the file
      output_path = path.join(ctx.roots.config.output_path(), @out)

      tasks.push(
        nodefn.call(mkdirp, path.dirname(output_path)).then ->
          nodefn.call(fs.writeFile, output_path, output)
      )

    W.all(tasks)

module.exports = ClientCompile
