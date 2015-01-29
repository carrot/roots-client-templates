path      = require 'path'
fs        = require 'fs'
Roots     = require 'roots'
RootsUtil = require 'roots-util'

_path  = path.join(__dirname, 'fixtures')
h = new RootsUtil.Helpers(base: _path)

# utils

compile_fixture = (fixture_name, done) ->
  @public = path.join(fixture_name, 'public')
  h.project.compile(Roots, fixture_name).done(done, ((err) -> console.error(err); done(err)))

before (done) ->
  h.project.install_dependencies('*', done)

after ->
  h.project.remove_folders('**/public')

# tests

describe 'errors', ->

  it 'should throw an error when base path not passed', ->
    @path = path.join(_path, 'error')
    project = new Roots(@path)
    (-> project.compile()).should.throw()

describe 'basics', ->

  before (done) -> compile_fixture.call(@, 'basic', -> done())

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

  before (done) -> compile_fixture.call(@, 'extract', -> done())

  it 'should compile a template to both client and static if extract is false', ->
    p1 = path.join(@public, 'tpl/all.js')
    h.file.exists(p1).should.be.ok
    h.file.has_content(p1).should.be.ok

    p2 = path.join(@public, 'tpl/template2.html')
    h.file.exists(p2).should.be.ok
    h.file.has_content(p2).should.be.ok

describe 'concat', ->

  before (done) -> compile_fixture.call(@, 'concat', -> done())

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

describe 'no_output', ->

  before (done) -> compile_fixture.call(@, 'no-out', -> done())

  it 'should compile templates with no output specified', ->
    p = path.join(@public, 'js/templates.js')
    h.file.exists(p).should.be.ok

describe 'compress', ->
  before (done) -> compile_fixture.call(@, 'compress', -> done())

  it 'should compress templates if the option is passed', ->
    p = path.join(@public, 'js/templates.js')
    h.file.exists(p).should.be.ok
    h.file.contains_match(p, '\n').should.not.be.ok

describe 'view_helper', ->
  before (done) -> compile_fixture.call(@, 'view_helper', -> done())

  it 'should output the correct path from the view helper', ->
    p = path.join(@public, 'index.html')
    h.file.exists(p).should.be.ok
    h.file.contains(p, "<script src='tpl/all.js'></script>").should.be.ok
