# This is an extremely simple example generator given refracted MSON input.
# It handles the following:
#
# * Simple types, enums, arrays, objects
# * Property descriptions
# * References
# * Mixins (Includes)
# * Arrays with members of different types
# * One Of properties (the first is always selected)
#
# It is missing support for many advanced features.
dereference = require './dereference'
defaultValue = require './default-value'
faker = require 'faker/locale/en'

generateExample = (root, context) ->
  switch root.element
    when 'boolean', 'string', 'number'
      # Use either the content, default, or make up a default value
      if root.content? then root.content else
        if root.attributes?.default isnt undefined
          root.attributes.default
        else
          if root.meta?.id then context.path.push root.meta.id.toLowerCase()
          value = context.defaultValue root, context.path
          if root.meta?.id then context.path.pop()
          value
    when 'enum'
      # Note: we *always* select the first choice!
      generateExample root.content[0], context
    when 'array'
      for item in root.content or []
        generateExample item, context
    when 'object'
      obj = {}
      for member in root.content
        if member.element == 'select'
          # Note: we *always* select the first choice!
          member = member.content[0].content[0]
        key = member.content.key.content
        if root.meta?.id then context.path.push root.meta.id.toLowerCase()
        context.path.push key.toLowerCase()
        obj[key] = if member.content.value
          generateExample member.content.value, context
        else
          context.defaultValue {element: 'string'}, context.path
        context.path.pop()
        if root.meta?.id then context.path.pop()
      obj
    else
      # This could return either `null` or `undefined`... not sure which
      # is best. Null means it will be serialized to JSON to show e.g.
      # the key name. For example: {'keyName': null} vs. {}. The downside
      # is that `null` may not actually be allowed.
      null

module.exports = (root, dataStructures, options) ->
  options ?= {}
  options.defaultValue ?= defaultValue
  origPath = options.path
  options.path ?= []

  if options.seed then faker.seed options.seed

  example = generateExample dereference(root, dataStructures), options

  options.path = origPath
  example
