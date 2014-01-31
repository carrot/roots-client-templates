path = require 'path'
fs = require 'fs'
_ = require 'lodash'
W = require 'when'

class ClientCompile

  constructor: (@opts) ->

  fs: ->
    category: 'precompiled'
    extract: (@opts.extract || true)
    ordered: false
    detect: ->
      # todo
