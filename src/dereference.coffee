# Dereference a refract element structure. After running, all types that are
# not one of `boolean`, `number`, `string`, `array`, `object`, `member`,
# `select`, and `option` should be replaced with the referenced elements.
# This includes elements by name (e.g. `"element": "MyType"`) and object
# includes where the member element is a `ref`.
# Circular references are **not** handled.

inherit = require './inherit'

module.exports = dereference = (root, dataStructures) ->
  switch root.element
    when 'enum', 'array'
      # Replace each item with a dereferenced version, which resolves any
      # references for the items in the array.
      root.content = for item in root.content or []
        dereference item, dataStructures
      root
    when 'object'
      # Objects are interesting because theys upport including other objects
      # as a form of inheritance. We go through each property and transclude
      # as necessary, then output object element with the modified list of
      # members.
      properties = if root.content then root.content.slice(0) else []
      i = 0
      while i < properties.length
        member = properties[i]
        i++
        if member.element == 'ref'
          i--
          ref = dataStructures[member.content.href]
          # Create a deep copy of the contents and set a reference on each
          # member, so we know where it came from.
          ref.content = JSON.parse JSON.stringify(ref.content)
          for property in ref.content
            property.meta ?= {}
            property.meta.ref = member.content.href
            property.meta.links ?= []
            property.meta.links.push
              relation: 'origin'
              href: 'http://refract.link/included-member/'
          # Here we need to transclude the content - we may be including any
          # number of elements from the parent, and each of these must be
          # processed to dereference it (if needed).
          properties.splice.apply properties, [i, 1].concat(ref.content)
          continue
        if member.content.key
          member.content.key = dereference member.content.key, dataStructures
        if member.content.value
          member.content.value =
            dereference member.content.value, dataStructures

      root.content = properties
      root
    else
      # Maybe it's a reference by element name?
      ref = dataStructures[root.element]

      if ref
        # It's a reference, so do the inheritance and any subsequent
        # dereferencing (e.g. of members) if necessary.
        dereference inherit(ref, root), dataStructures
      else
        # Just return the item itself, could be a simple type or we
        # just don't know how to handle it!
        root
