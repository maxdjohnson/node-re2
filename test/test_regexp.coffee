NativeRegExp  = RegExp
{RegExp}      = require('../lib')
should        = require('should')

describe 'RegExp', ->
  it 'should trivially match identical strings', ->
    new RegExp('a').test('a').should.be.true

  it 'should match everywhere', ->
    new RegExp('bar').test('foobarbaz').should.be.true

