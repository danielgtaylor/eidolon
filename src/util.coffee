# Utility functions

# Create a new link in an element's metadata. This creates `meta` and
# `meta.links` if needed.
exports.createLink = (element, link) ->
  element.meta ?= {}
  element.meta.links ?= []
  element.meta.links.push link
