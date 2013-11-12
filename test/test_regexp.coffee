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

check_unsupported = (expression) ->
  assert.throws ->
    new RE2RegExp(expression)

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

  it 'should correctly handle capturing groups', ->
    check_exec('a(.*)z', 'abcdefz')

  it 'should correctly handle non-capturing groups', ->
    check_exec('a(?:.*)z', 'abcdefz')

  it 'should correctly handle alternatives', ->
    check_exec('red|apple', 'red')
    check_exec('red|apple', 'apple')
    check_exec('red|apple', 'neither')

  it 'should correctly handle repeated patterns', ->
    check_exec('a{3}', 'aaa')
    check_exec('a{3}', 'aaaa')
    check_exec('a{3}', 'aa')
    check_exec('z{3,5}', 'zz')
    check_exec('z{3,5}', 'zzz')
    check_exec('z{3,5}', 'zzzzz')
    check_exec('z{3,5}', 'zzzzzz')

  it 'should correctly handle word boundaries', ->
    check_exec('\\b#yolo', '#yolobro')
    check_exec('\\b#yolo', 'bro#yolo')
    check_exec('\\b#yolo', 'bro, #yolo')
    check_exec('\\B#yolo', '#yolobro')
    check_exec('\\B#yolo', 'bro#yolo')
    check_exec('\\B#yolo', 'bro, #yolo')

  it 'should correctly handle digits', ->
    check_exec('\\d', '1')
    check_exec('\\d', 'a')
    check_exec('\\D', '1')
    check_exec('\\D', 'a')

  it 'should correctly handle space chars', ->
    spaces = " \f\n\r\t"
    check_exec('\\s', space) for space in spaces
    check_exec('\\S', space) for space in spaces

  it 'should correctly handle alphanumerics', ->
    check_exec('\\w', 'a')
    check_exec('\\w', '1')
    check_exec('\\w', '*')
    check_exec('\\W', 'a')
    check_exec('\\W', '1')
    check_exec('\\W', '*')

  it 'should respect non-greedy qualifiers', ->
    check_exec('<.*?>', '<div><div>foo</div></div>')
    check_exec('\\d+?', '123abc')
    check_exec('<.*>', '<div><div>foo</div></div>')
    check_exec('\\d+', '123abc')

  it 'should match the right thing when it has several options', ->
    check_exec('a*', 'baaabaaaaaabaaab')

  ###
  # Unsupported javascript regex features
  ###

  it 'should fail when the expression contains a lookahead', ->
    check_unsupported(/a(?=b)/)

  it 'should fail when the expression contains a negated lookahead', ->
    check_unsupported(/a(?!b)/)

  # TODO Support by rewriting the expression.
  it 'fails when the expression contains a \\c sequence', ->
    check_unsupported('\\cM')

  # TODO Figure this out. Works in python bindings...
  it 'doesn\'t consider unicode whitespace as whitespace', ->
    failing_spaces = "\v\u00A0\u1680\u180e\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000"
    assert.equal(new RE2RegExp('\\s').test(failing_space), false) for failing_space in failing_spaces
    assert.equal(new    RegExp('\\s').test(failing_space), true)  for failing_space in failing_spaces

  it 'should fail when the expression contains a backreference', ->
    check_unsupported('/apple(,)\\sorange\\1/')

