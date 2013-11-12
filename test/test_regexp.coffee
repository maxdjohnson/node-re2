{RE2RegExp} = require('../lib')
should      = require('should')
assert      = require('assert')

check_properties = (args...) ->
  props_to_check = ['global', 'ignoreCase', 'multiline']
  a = new RE2RegExp(args...)
  b = new RegExp(args...)
  a[prop].should.eql b[prop] for prop in props_to_check

check_exec = (args...) ->
  str = args.pop()
  a = new RE2RegExp(args...)
  b = new RegExp(args...)
  assert.deepEqual a.exec(str), b.exec(str)

all_combinations = (all_flags) ->
  all_combos = []
  for i in [0...(1 << all_flags.length)] # 1 bit for each flag
    flags = ''
    for flag, j in all_flags
      if i & (1 << j)
        flags += flag
    all_combos.push(flags)
  return all_combos

describe 'RE2RegExp', ->
  it 'should trivially match identical strings', ->
    new RE2RegExp('a').test('a').should.be.true

  it 'should match everywhere', ->
    new RE2RegExp('bar').test('foobarbaz').should.be.true

  it 'should parse flags properly', ->
    flags_to_check = 'gim'
    check_properties('test', flags) for flags in all_combinations(flags_to_check)

  it 'should copy flags properly', ->
    flags_to_check = 'gim'
    check_properties(new RegExp('test', flags)) for flags in all_combinations(flags_to_check)

  it 'should handle the g flag correctly', ->
    exp = '[a-z]'
    flags = 'g'
    str = 'abcd'
    a = new RE2RegExp(exp, flags)
    b = new RegExp(exp, flags)
    while true
      ma = a.exec(str)
      mb = b.exec(str)
      should(mb == ma)
      break if ma == null

  it 'should handle the absence of the g flag correctly', ->
    exp = '[a-z]'
    flags = ''
    str = 'abcd'
    a = new RE2RegExp(exp, flags)
    b = new RegExp(exp, flags)
    for i in [1..4]
      ma = a.exec(str)
      mb = b.exec(str)
      assert.deepEqual ma, mb
      break if ma == null

  it 'should handle the i flag correctly', ->
    check_exec('bar', 'i', 'foobarbaz')
    check_exec('Bar', 'i', 'foobArbaz')

  it 'should handle the absence of the i flag correctly', ->
    check_exec('bar', 'foobarbaz')
    check_exec('Bar', 'foobArbaz')

  it 'should handle the m flag correctly', ->
    check_exec('^bar$', 'm', 'foo\nbar\nbaz')

  it 'should handle the absence of the m flag correctly', ->
    check_exec('^bar$', 'foo\nbar\nbaz')

  it 'should match the output of the native regex', ->
    check_exec('bar', 'foobarbaz')

  it 'should correctly handle matching groups', ->
    check_exec('a(.*)z', 'abcdefz')


