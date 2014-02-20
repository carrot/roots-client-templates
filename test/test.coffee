path   = require 'path'
fs     = require 'fs'
should = require 'should'
glob   = require 'glob'
rimraf = require 'rimraf'
Roots  = require 'roots'
W      = require 'when'
nodefn = require 'when/node/function'
_path  = path.join(__dirname, 'fixtures')
run = require('child_process').exec

# setup, teardown, and utils

should.file_exist = (path) ->
  fs.existsSync(path).should.be.ok

should.have_content = (path) ->
  fs.readFileSync(path).length.should.be.above(1)

should.contain = (path, content) ->
  fs.readFileSync(path, 'utf8').indexOf(content).should.not.equal(-1)

before (done) ->
  tasks = []
  for d in glob.sync("#{_path}/*/package.json")
    p = path.dirname(d)
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d}"
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks, -> done())

after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')

# tests

describe 'errors', ->
  it 'should throw an error when no base is defined', ->
    @path = path.join(_path, 'error')
    project = ( -> new Roots(@path) ).should.throw("path does not exist")

describe 'client templates', ->

  before (done) ->
    @path = path.join(_path, 'basic')
    @public = path.join(@path, 'public')
    project = new Roots(@path)
    project.compile()
      .on('error', done)
      .on('done', done)

  it 'should compile templates under their local path key', ->
    p = path.join(@public, 'tpl1/1.js')
    should.contain(p, 'template1')
    should.contain(p, 'cat/dog')

  it 'should precompile a basic template', ->
    p = path.join(@public, 'tpl1/1.js')
    should.file_exist(p)
    should.have_content(p)

  it 'should compile a template to both client and static if extract is false', ->
    p1 = path.join(@public, 'tpl2/2.js')
    should.file_exist(p1)
    should.have_content(p1)

    p2 = path.join(@public, 'tpl2/template2.html')
    should.file_exist(p2)
    should.have_content(p2)

  it 'should compile templates separately if concat is false', ->
    p1 = path.join(@public, 'tpl3/3.js')
    should.file_exist(p1)
    should.have_content(p1)

    p2 = path.join(@public, 'tpl3/template3.js')
    should.file_exist(p2)
    should.have_content(p2)

    p3 = path.join(@public, 'tpl3/template4.js')
    should.file_exist(p3)
    should.have_content(p3)

  it 'should compile templates with no output specified', ->
    p = path.join(@public, 'js/templates.js')
    should.file_exist(p)
