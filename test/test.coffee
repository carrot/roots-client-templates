path   = require 'path'
fs     = require 'fs'
should = require 'should'
glob   = require 'glob'
rimraf = require 'rimraf'
Roots  = require 'roots'

should.file_exist = (path) ->
  fs.existsSync(path).should.be.ok

should.have_content = (path) ->
  fs.readFileSync(path).length.should.be.above(1)

describe 'client templates', ->

  before (done) ->
    @path = path.join(__dirname, 'fixtures/basic')
    @public = path.join(@path, 'public')
    (new Roots(@path)).compile()
      .on('error', done)
      .on('done', done)

  it 'should work'

after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')
