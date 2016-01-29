# Eidolon
Generate examples and [JSON Schema](http://json-schema.org/) from [Refract](https://github.com/refractproject/refract-spec#refract) data structures. Data structures can come from [MSON](https://github.com/apiaryio/mson#markdown-syntax-for-object-notation) or other input sources.

Given the following MSON attributes from e.g. [API Blueprint](https://apiblueprint.org/):

```apib
+ Attributes
  + name: Daniel (required) - User's first name
  + age: 10 (required, number) - Age in years
```

It would generate the following JSON example and JSON Schema:

```json
{
  "name": "Daniel",
  "age": 10
}
```

```json
{
  "type": "object",
  "required": ["name", "age"],
  "properties": {
    "name": {
      "type": "string",
      "description": "User's first name"
    },
    "age": {
      "type": "number",
      "description": "Age in years"
    }
  }
}
```

## Installation & Usage

This project is available via `npm`:

```sh
npm install eidolon
```

There are two ways to use the module: either via module-level methods or by instantiating a class instance.

```js
import eidolon, {Eidolon} from 'eidolon';

const input = {"element": "string", "content": "Hello"};
const dataStructures = [];

// Method 1: module methods
example1 = eidolon.example(input, dataStructures);
schema1 = eidolon.schema(input, dataStructures);

// Method 2: class instance
instance = new Eidolon(dataStructures);
example2 = instance.example(input);
schema2 = instance.schema(input);
```

Choose whichever method better suits your use case.

## Features

The following features are supported by the example and JSON Schema generators. Note that not all MSON features are supported (yet)!

### Example Generator

* Simple types, enums, arrays, objects
* Property descriptions
* References
* Mixins (Includes)
* Arrays with members of different types
* One Of properties (the first is always selected)

### JSON Schema Generator

* Simple types, enums, arrays, objects
* Property descriptions
* Required, default, nullable properties
* References
* Mixins (Includes)
* Arrays with members of different types
* One Of (mutually exclusive) properties

### Notable Missing Features

The following list of features in no particular order are known to be missing or cause issues. Please feel free to open a pull request with new features and fixes based on this list! *wink wink nudge nudge* :beers:

* Circular references
* Variable values
* Variable property names
* Variable type names

## License

Copyright &copy; 2016 Daniel G. Taylor

http://dgt.mit-license.org/
