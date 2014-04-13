path   = require 'path'
fs     = require 'fs'
should = require 'should'
Roots  = require 'roots'
RootsUtil = require 'roots-util'

_path  = path.join(__dirname, 'fixtures')
h = new RootsUtil.Helpers(base: _path)

# utils
compile_fixture = (fixture_name, done) ->
  h.project.compile(Roots, fixture_name, done)
  return path.join(fixture_name, 'public')

before (done) ->
  h.project.install_dependencies('*', done)

after ->
  h.project.remove_folders('**/public')

# tests
describe 'errors', ->
  it 'should throw an error when no base is defined', ->
    @path = path.join(_path, 'error')
    project = (-> new Roots(@path)).should.throw("path does not exist")

describe 'basics', ->
  before (done) -> @public = compile_fixture('basic', done)

  it 'should precompile a basic template', ->
    p = path.join(@public, 'tpl/all.js')
    h.file.exists(p).should.be.ok
    h.file.has_content(p).should.be.ok

  it 'should still compile other templates normally', ->
    p = path.join(@public, 'index.html')
    h.file.exists(p).should.be.ok
    h.file.has_content(p).should.be.ok

  it 'should compile templates under their local path key', ->
    p = path.join(@public, 'tpl/all.js')
    h.file.contains(p, 'template1').should.be.ok
    h.file.contains(p, path.normalize('cat/dog')).should.be.ok

  it 'not compile templates that would break a normal jade compile', ->
    p = path.join(@public, 'tpl/all.js')
    h.file.contains(p, 'template2').should.be.ok

describe 'extract', ->
  before (done) -> @public = compile_fixture('extract', done)

  it 'should compile a template to both client and static if extract is false', ->
    p1 = path.join(@public, 'tpl/all.js')
    h.file.exists(p1).should.be.ok
    h.file.has_content(p1).should.be.ok

    p2 = path.join(@public, 'tpl/template2.html')
    h.file.exists(p2).should.be.ok
    h.file.has_content(p2).should.be.ok

describe 'concat', ->
  before (done) -> @public = compile_fixture('concat', done)

  it 'should compile templates separately if concat is false', ->
    p1 = path.join(@public, 'tpl/helper.js')
    h.file.exists(p1).should.be.ok
    h.file.has_content(p1).should.be.ok

    p2 = path.join(@public, 'tpl/template3.js')
    h.file.exists(p2).should.be.ok
    h.file.has_content(p2).should.be.ok

    p3 = path.join(@public, 'tpl/template4.js')
    h.file.exists(p3).should.be.ok
    h.file.has_content(p3).should.be.ok

describe 'no output', ->
  before (done) -> @public = compile_fixture('no-out', done)

  it 'should compile templates with no output specified', ->
    p = path.join(@public, 'js/templates.js')
    h.file.exists(p).should.be.ok
