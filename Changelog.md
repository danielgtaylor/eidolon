# 1.2.1 - 2016-02-16

- Fix crash when handling objects or references to objects with no content.

# 1.2.0 - 2016-02-02

- Add reference information to dereferenced data structures via the `meta.ref` property, which contains a string ID of the reference from which the element is derived. This works for both type references and object mixins/includes.

# 1.1.0 - 2016-02-01

- Expose a `dereference` function. Both the example and schema generators now use this internally to simplify their specific code.

# 1.0.0 - 2016-01-29

- Initial release.
