# Eidolon

[![Build Status](http://img.shields.io/travis/danielgtaylor/eidolon/master.svg)](https://travis-ci.org/danielgtaylor/eidolon) [![Coverage Status](http://img.shields.io/coveralls/danielgtaylor/eidolon/master.svg)](https://coveralls.io/r/danielgtaylor/eidolon) [![NPM version](http://img.shields.io/npm/v/eidolon.svg)](https://www.npmjs.org/package/eidolon) [![License](http://img.shields.io/npm/l/eidolon.svg)](https://www.npmjs.org/package/eidolon)

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
  "$schema": "http://json-schema.org/draft-04/schema#",
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
const dataStructures = {};

let example, schema;

// Method 1: module methods
example = eidolon.example(input, dataStructures);
schema = eidolon.schema(input, dataStructures);

// Method 2: class instance
const instance = new Eidolon(dataStructures);
example = instance.example(input);
schema = instance.schema(input);
```

Choose whichever method better suits your use case.

#### Example & Schema Serialization

Examples and JSON Schema are created as plain Javascript objects. As such, they can be serialized into various formats, such as JSON, YAML, and other more esoteric formats. In the case of JSON Schema, it probably makes the most sense to stick with JSON.

```js
example = instance.example(input);

// Print as JSON
console.log(JSON.stringify(example, null, 2));

// Print as YAML (after `npm install js-yaml`)
import yaml from 'js-yaml';
console.log(yaml.safeDump(example));
```

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
* Extend element support
* Remote referenced elements (e.g. via HTTP)
* Namespace prefixes

## Reference

### `eidolon.Eidolon([dataStructures])`

This class is used to save state between calls to `example` and `schema`. It is used just like the functions below, except that you pass your data structures to the constructor instead of to each method.

```js
import {Eidolon} from 'eidolon';

const instance = new Eidolon();
const input = {element: 'string', content: 'hello'};

let example = instance.example(input);
let schema = instance.schema(input);
```

### `eidolon.example(input, [dataStructures])`

Generate a new example from the given input refract object and an optional mapping of data structures, where the key is the data structure name and the value is the data structure definition.

```js
import eidolon from 'eidolon';

const input = {element: 'string', content: 'hello'};
let example = eidolon.example(input);
```

### `eidolon.schema(input, [dataStructures])`

Generate a new JSON schema from the given input refract object and an optional mapping of data structures, where the key is the data structure name and the value is the data structure definition.

```js
import eidolon from 'eidolon';

const input = {element: 'string', content: 'hello'};
let schema = eidolon.schema(input);
```

### `eidolon.inherit(base, element)`

Generate a new element with merged properties from both `base` and `element`, taking care to prevent duplicate members. This utility can be used when traversing the element tree.

```js
import eidolon from 'eidolon';

const base = {
  element: 'number',
  meta: {
    id: 'NullableNumber',
    default: 0
  },
  attributes: {
    typeAttributes: ['nullable']
  }
};

const element = {
  element: 'NullableNumber',
  attributes: {
    default: 2
  },
  content: 10
}

let merged = eidolon.inherit(base, element);

// Merged now looks like:
{
  element: 'number',
  attributes: {
    default: 2,
    typeAttributes: ['nullable']
  },
  content: 10
}
```

## License

Copyright &copy; 2016 Daniel G. Taylor

http://dgt.mit-license.org/
