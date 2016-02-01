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

defaultValue = (type) ->
  switch type
    when 'boolean' then true
    when 'number' then 1
    when 'string' then 'Hello, world!'

generateExample = (root) ->
  switch root.element
    when 'boolean', 'string', 'number'
      # Use either the content, default, or make up a default value
      if root.content? then root.content else
        if root.attributes?.default isnt undefined
          root.attributes.default
        else
          defaultValue(root.element)
    when 'enum'
      # Note: we *always* select the first choice!
      generateExample root.content[0]
    when 'array'
      for item in root.content or []
        generateExample item
    when 'object'
      obj = {}
      for member in root.content
        if member.element == 'select'
          # Note: we *always* select the first choice!
          member = member.content[0].content[0]
        key = member.content.key.content
        obj[key] = if member.content.value
          generateExample member.content.value
        else
          defaultValue 'string'
      obj

module.exports = (root, dataStructures) ->
  generateExample dereference(root, dataStructures)
