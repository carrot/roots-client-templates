path      = require 'path'
fs        = require 'fs'
_         = require 'lodash'
W         = require 'when'
minimatch = require 'minimatch'
umd       = require 'umd'
UglifyJS  = require 'uglify-js'
RootsUtil = require 'roots-util'

module.exports = (opts) ->
  class ClientCompile

    constructor: (roots) ->
      @util = new RootsUtil(roots)

      @opts = _.defaults opts,
        out:      'js/templates.js'
        name:     'templates'
        pattern:  '**'
        concat:   true
        extract:  true
        compress: false
        category: "precompiled"

      {@extract, @concat, @category, @name, @out, @compress} = @opts

      if !@opts.base?
        throw new Error('you must provide a base template path')

      @opts.base = path.normalize(@opts.base)
      @pattern = path.join(@opts.base, @opts.pattern)

      @templates = {}

      # if you are concatenating, you can choose extract or not
      # if you are not concatenating, you must write the file
      @write = if @concat then !@extract else true

      roots.config.locals ?= {}
      roots.config.locals.client_templates = (prefix = '') =>
        "<script src='#{prefix}#{@opts.out}'></script>"

    fs: ->
      extract: @extract
      ordered: false
      detect: (f) => minimatch(f.relative, @pattern)

    compile_hooks: ->
      before_pass: before_hook.bind(@)
      after_file: after_hook.bind(@)
      write: write_hook.bind(@)

    category_hooks: ->
      after: after_category.bind(@)

    # @api private

    # before the last pass, save out the original content
    before_hook = (ctx) ->
      if ctx.index == ctx.file.adapters.length
        ctx.file.original_content = ctx.file.content
        # we client-compile the file by ourselves anyway,
        # so letting roots compile it would be useless
        # since we either replace ctx.content if not @concat
        # or we don't write the file at all otherwise
        ctx.content = ""

    after_hook = (ctx) ->
      # last valid adapter is assumed to be your precompile target
      adapter = _.find(_.clone(ctx.adapters).reverse(), (a) -> a.name)

      # if this is the first template with this adapter, set up the store
      @templates[adapter.name] ?= { adapter: adapter, all: [] }

      # client-compile the file and add it to the store
      adapter.compileClient(ctx.original_content, {
        filename: ctx.file.path
      }).then (out) =>
        # naming the template key

        # - remove roots root
        tpl_name = ctx.file.path.replace(ctx.roots.root,'')

        # - remove templates root
        tpl_name = tpl_name.split(@opts.base)[1]

        # - cut the file extension(s) and remove leading /
        tpl_name = tpl_name.split('.')[0]

        @templates[adapter.name].all.push(name: tpl_name, content: out.result)

        # if individual files wanted for templates, wrap & replace content
        if not @concat then ctx.content = umd(tpl_name, out.result)

        return @write

    write_hook = (ctx) ->
      # if concat is true, prevent write
      if @concat then return false

      # if concat is not true, write with `.js` at the end
      return { extension: 'js' }

    after_category = (ctx, category) ->
      tasks = []

      # for each category in templates
      for name, category of @templates
        output = ""

        # print client helpers to out file
        output += category.adapter.clientHelpers()

        # add templates to the exported object if necessary
        if @concat
          output += "return {"
          for tpl in category.all
            if tpl.name.indexOf('/') is 0
              tpl.name = tpl.name.substring(tpl.name.indexOf('/')+1)
            output += "\"#{tpl.name}\": #{tpl.content},"
          output = output.slice(0,-1)
          output += "};"

        # add umd wrapper
        output = umd(@name, output)

        if @compress
          output = UglifyJS.minify(output, fromString: true).code

        tasks.push(@util.write(@out, output))

      W.all(tasks)
