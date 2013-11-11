{RE2RegExp} = require('../lib')
should      = require('should')

check_properties = (args...) ->
  props_to_check = ['global', 'ignoreCase', 'multiline']
  a = new RE2RegExp(args...)
  b = new RegExp(args...)
  b[prop].should.eql a[prop] for prop in props_to_check

check_exec = (args...) ->
  str = args.pop()
  a = new RE2RegExp(args...)
  b = new RegExp(args...)
  a.exec(str).should.eql b.exec(str)

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

  it 'should match the output of the native regex', ->
    check_exec('bar', 'foobarbaz')
