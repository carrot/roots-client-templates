path      = require 'path'
fs        = require 'fs'
_         = require 'lodash'
W         = require 'when'
nodefn    = require 'when/node/function'
minimatch = require 'minimatch'
umd       = require 'umd'
uuid      = require 'node-uuid'

class ClientCompile

  constructor: (opts) ->
    @extract = if opts.extract == false then false else true
    @pattern = opts.path || throw new Error('you must provide a path')
    @concat = if opts.concat == false then false else true
    @category = "precompiled-#{uuid.v1()}" # uuid - multiple instances, no conflict
    @name = opts.name || 'templates'
    @templates = {}
    @out = opts.out || 'js/templates.js'

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
      # - cut the first folder name in the pattern
      tpl_name = tpl_name.replace(path.dirname(@pattern).split(path.sep)[0],'')
      # - remove any leading slashes left over
      tpl_name = tpl_name.replace(new RegExp("^\\#{path.sep}+"), '')
      # - cut the file extension(s)
      tpl_name = _.last(tpl_name.split(path.sep)).split('.')[0]
      # - TODO: split by slash and add ad a proper object
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
        output += "\"#{tpl.name}\": #{tpl.content}," for tpl in category.all # TODO: uglify?
        output = output.slice(0,-1)
        output += "};"

      # add umd wrapper
      output = umd(@name, output)

      # write the file
      output_path = path.join(ctx.roots.config.output_path(), @out)
      tasks.push(nodefn.call(fs.writeFile, output_path, output))

    W.all(tasks)

module.exports = ClientCompile
