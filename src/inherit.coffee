# Handle MSON inheritance. This is interesting because certain attributes,
# items, members, etc can be overridden. For example, the `id` property is
# overridden to be any valid `string` below:
#
# # My Type
# + id (number)
# + name (string)
#
# # Another Type (My Type)
# + id (string)

# Make sure all members are unique, removing all duplicates before the last
# occurence of the member key name.
uniqueMembers = (content) ->
  known = {}

  i = 0
  while i < content.length
    if content[i].element is 'member'
      key = content[i].content.key.content
      if known[key] isnt undefined
        # First, we swap the members so location is preserved, then
        # remove the old member.
        content[known[key]] = content[i]
        content.splice(i, 1)
        continue
      else
        # Save the location of the *first* instance of this key
        known[key] = i
    i++
  content

# Have `element` inherit from `base`.
inherit = (base, element) ->
  # First, we do a deep copy of the base (parent) element
  combined = JSON.parse(JSON.stringify(base))

  # Next, we copy or overwrite any metadata and attributes
  if base.meta?.id?
    delete combined.meta.id
    combined.meta.ref = base.meta.id
    combined.meta.links ?= []
    combined.meta.links.push
      relation: 'origin'
      href: 'http://refract.link/inherited/'

    # Also, set individual member ref info, but only if it isn't already set!
    if combined.content?.length
      for item in combined.content
        if item.element
          unless item.meta and item.meta.ref
            item.meta ?= {}
            item.meta.ref = base.meta.id
            item.meta.links ?= []
            item.meta.links.push
              relation: 'origin'
              href: 'http://refract.link/inherited-member/'

  if element.meta
    combined.meta ?= {}
    combined.meta[key] = value for own key, value of element.meta

  if element.attributes
    combined.attributes ?= {}
    combined.attributes[key] = value for own key, value of element.attributes

  # Lastly, we combine the content if we can. For simple types, this means
  # overwriting the content. For arrays it adds to the content list and for
  # objects is adds *or* overwrites (if an existing key already exists).
  if element.content
    if combined.content?.push or element.content?.push
      # This could be an object or array
      combined.content ?= []
      for item in element.content
        combined.content.push item

      if combined.content.length and combined.content[0].element is 'member'
        # This is probably an object - remove duplicate keys!
        uniqueMembers combined.content
    else
      # Not an array or object, just overwrite the content if it exists.
      if element.content?
        combined.content = element.content

  combined

module.exports = {uniqueMembers, inherit}
