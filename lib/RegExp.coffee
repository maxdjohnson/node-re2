{RE2} = require('../build/Release/re2')
RegExpNative = RegExp

parseFlags = (obj, flags) ->
  obj.global = obj.ignoreCase = obj.multiline = false
  for flag in flags
    switch flag
      when 'g' then obj.global = true
      when 'i' then obj.ignoreCase = true
      when 'm' then obj.multiline = true
      else throw new SyntaxError('Invalid flags supplied to RegExp constructor \'' + flag + '\'')

module.exports = class RegExp
  constructor: (expression, flags='') ->

    if typeof expression == 'object' and expression instanceof RegExpNative
      expression = expression.source
      this.global = expression.global
      this.ignoreCase = expression.ignoreCase
      this.multiline = expression.multiline
    else
      expression = String(expression)
      parseFlags this, flags

    re2Flags = ''
    if this.ignoreCase
      re2Flags += 'i'
    if this.multiline
      re2Flags += 'm'
    if re2Flags.length > 0
      re2Flags = '(?' + re2Flags + ')'
    this._re2 = new RE2(re2Flags + expression)

    if expression.length == 0
      expression = '(?:)'
    this.lastIndex = 0
    this.source = expression

  exec: (str) ->
    match = this._re2.match(str, this.lastIndex)
    if match.length == 0
      return null
    match.index = str.indexOf(match[0], this.lastIndex)
    match.input = str
    if this.global
      this.lastIndex = match.index + 1
    return match

  test: (str) ->
    return this.exec(str) != null

  toString: () ->
    return this.source
