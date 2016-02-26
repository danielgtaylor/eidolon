dereference = require './dereference'
generateExample = require './example'
generateSchema = require './schema'
{inherit} = require './inherit'

# This class is initialized with and saves the data structures that can be
# referenced and used when generating examples and schemas. It is an alternative
# to the module-level shortcuts exported below that each require a list of
# data structures to be passed with each invocation.
class Eidolon
  constructor: (@structures = {}) ->

  dereference: (element) ->
    dereference element, @structures

  example: (element) ->
    generateExample element, @structures

  schema: (element) ->
    generateSchema element, @structures

module.exports =
  Eidolon: Eidolon
  dereference: dereference
  example: generateExample
  inherit: inherit
  schema: generateSchema
