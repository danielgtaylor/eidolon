# 1.5.0 - 2016-03-25

- Handle circular references when dereferencing, by stopping processing and adding in a circular reference origin link relation.

# 1.4.0 - 2016-03-02

- Generate smart random data when elements have no sample or default value set. This can now be overridden with your own `defaultValue` function.

# 1.3.0 - 2016-02-25

- Add origin link relations to inherited elements, inherited members, and included members.
- Replace duplicate inherited or included members in-place to preserve member order.

# 1.2.2 - 2016-02-23

- Add missing `ref` data to inherited members.

# 1.2.1 - 2016-02-16

- Fix crash when handling objects or references to objects with no content.

# 1.2.0 - 2016-02-02

- Add reference information to dereferenced data structures via the `meta.ref` property, which contains a string ID of the reference from which the element is derived. This works for both type references and object mixins/includes.

# 1.1.0 - 2016-02-01

- Expose a `dereference` function. Both the example and schema generators now use this internally to simplify their specific code.

# 1.0.0 - 2016-01-29

- Initial release.
