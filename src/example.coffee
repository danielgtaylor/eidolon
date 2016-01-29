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
inherit = require './inherit'

defaultValue = (type) ->
  switch type
    when 'boolean' then true
    when 'number' then 1
    when 'string' then 'Hello, world!'

module.exports = generateExample = (root, dataStructures) ->
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
      generateExample root.content[0], dataStructures
    when 'array'
      for item in root.content or []
        generateExample item, dataStructures
    when 'object'
      obj = {}
      properties = root.content.slice(0)
      i = 0
      while i < properties.length
        member = properties[i]
        i++
        if member.element == 'ref'
          ref = dataStructures[member.content.href]
          i--
          properties.splice.apply properties, [i, 1].concat(ref.content)
          continue
        else if member.element == 'select'
          # Note: we *always* select the first choice!
          member = member.content[0].content[0]
        key = member.content.key.content
        obj[key] = if member.content.value
          generateExample member.content.value, dataStructures
        else
          defaultValue 'string'
      obj
    else
      ref = dataStructures[root.element]
      if ref
        generateExample inherit(ref, root), dataStructures
