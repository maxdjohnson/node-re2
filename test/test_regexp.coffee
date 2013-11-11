{RE2RegExp} = require('../lib')
should      = require('should')

check = (args...) ->
  str = args.pop()
  a = new RE2RegExp(args...)
  b = new RegExp(args...)
  a.exec(str).should.eql b.exec(str)

describe 'RE2RegExp', ->
  it 'should trivially match identical strings', ->
    new RE2RegExp('a').test('a').should.be.true

  it 'should match everywhere', ->
    new RE2RegExp('bar').test('foobarbaz').should.be.true

  it 'should match the output of the native regex', ->
    check('bar', 'foobarbaz')
