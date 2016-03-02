defaultValue = require './default-value'
dereference = require './dereference'
generateExample = require './example'
generateSchema = require './schema'
{inherit} = require './inherit'

# This class is initialized with and saves the data structures that can be
# referenced and used when generating examples and schemas. It is an alternative
# to the module-level shortcuts exported below that each require a list of
# data structures to be passed with each invocation.
class Eidolon
  constructor: (@structures = {}, @options = {}) ->
    @options.defaultValue ?= defaultValue

  dereference: (element) ->
    dereference element, @structures

  example: (element, options=@options) ->
    generateExample element, @structures, options

  schema: (element) ->
    generateSchema element, @structures

module.exports =
  Eidolon: Eidolon
  defaultValue: defaultValue
  dereference: dereference
  example: generateExample
  inherit: inherit
  schema: generateSchema
