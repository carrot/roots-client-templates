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

compile_fixture = (fixture_name, done) ->
  @path = path.join(_path, fixture_name)
  @public = path.join(@path, 'public')
  project = new Roots(@path)
  project.compile().on('error', done).on('done', done)

before (done) ->
  tasks = []
  for d in glob.sync("#{_path}/*/package.json")
    p = path.dirname(d)
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d}"
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks).then(-> done())

after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')

# tests

describe 'errors', ->

  it 'should throw an error when no base is defined', ->
    @path = path.join(_path, 'error')
    project = (-> new Roots(@path)).should.throw("path does not exist")

describe 'basics', ->

  before (done) -> compile_fixture.call(@, 'basic', done)

  it 'should precompile a basic template', ->
    p = path.join(@public, 'tpl/all.js')
    should.file_exist(p)
    should.have_content(p)

  it 'should still compile other templates normally', ->
    p = path.join(@public, 'index.html')
    should.file_exist(p)
    should.have_content(p)

  it 'should compile templates under their local path key', ->
    p = path.join(@public, 'tpl/all.js')
    should.contain(p, 'template1')
    should.contain(p, 'cat/dog')

  it 'not compile templates that would break a normal jade compile', ->
    p = path.join(@public, 'tpl/all.js')
    should.contain(p, 'template2')

describe 'extract', ->

  before (done) -> compile_fixture.call(@, 'extract', done)

  it 'should compile a template to both client and static if extract is false', ->
    p1 = path.join(@public, 'tpl/all.js')
    should.file_exist(p1)
    should.have_content(p1)

    p2 = path.join(@public, 'tpl/template2.html')
    should.file_exist(p2)
    should.have_content(p2)

describe 'concat', ->

  before (done) -> compile_fixture.call(@, 'concat', done)

  it 'should compile templates separately if concat is false', ->
    p1 = path.join(@public, 'tpl/helper.js')
    should.file_exist(p1)
    should.have_content(p1)

    p2 = path.join(@public, 'tpl/template3.js')
    should.file_exist(p2)
    should.have_content(p2)

    p3 = path.join(@public, 'tpl/template4.js')
    should.file_exist(p3)
    should.have_content(p3)

describe 'no output', ->

  before (done) -> compile_fixture.call(@, 'no-out', done)

  it 'should compile templates with no output specified', ->
    p = path.join(@public, 'js/templates.js')
    should.file_exist(p)
