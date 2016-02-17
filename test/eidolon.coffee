assert = require 'assert'
{Eidolon} = require '../src/eidolon'
fs = require 'fs'
glob = require 'glob'
path = require 'path'

# Make `glob` and `require` all work from the same path
process.chdir __dirname

# Test each fixture against its expected example and schema output
glob.sync('./fixtures/*-refract.json').forEach (filename) ->
  describe path.basename(filename, '-refract.json'), ->
    input = require filename
    structures = {}

    exists = false
    structuresFilename = filename.replace(/-refract\.json/, '-structures.json')
    try
      fs.statSync structuresFilename
      exists = true

    if exists
      # If any data structures are defined, get them. This is useful for
      # resolving references.
      structures = require structuresFilename

    eidolon = new Eidolon structures

    it 'Generates an example', ->
      expected = require filename.replace(/-refract\.json/, '-example.json')
      example = eidolon.example input
      assert.deepEqual example, expected

    it 'Generates a schema', ->
      expected = require filename.replace(/-refract\.json/, '-schema.json')
      schema = eidolon.schema input
      assert.deepEqual schema, expected

describe 'Dereferencing', ->
  refract =
    element: 'MyType'

  dataStructures =
    MyType:
      element: 'object'
      meta:
        id: 'MyType'
      content: [
          element: 'member'
          content:
            key:
              element: 'string'
              content: 'foo'
            value:
              element: 'FooType'
              content: null
        ,
          element: 'ref'
          content:
            href: 'BarType'
        ,
          element: 'member'
          content:
            key:
              element: 'string'
              content: 'baz'
            value:
              element: 'boolean'
              content: true
      ]
    FooType:
      element: 'number'
      meta:
        id: 'FooType'
      content: 5
    BarType:
      element: 'object'
      meta:
        id: 'BarType'
      content: [
        element: 'member'
        content:
          key:
            element: 'string'
            content: 'bar'
          value:
            element: 'string'
            content: 'Hello'
      ]

  expected =
    element: 'object'
    meta:
      ref: 'MyType'
    content: [
        element: 'member'
        content:
          key:
            element: 'string'
            content: 'foo'
          value:
            element: 'number'
            meta:
              ref: 'FooType'
            content: 5
      ,
        element: 'member'
        meta:
          ref: 'BarType'
        content:
          key:
            element: 'string'
            content: 'bar'
          value:
            element: 'string'
            content: 'Hello'
      ,
        element: 'member'
        content:
          key:
            element: 'string'
            content: 'baz'
          value:
            element: 'boolean'
            content: true
    ]

  eidolon = new Eidolon dataStructures
  dereferenced = eidolon.dereference refract

  it 'Dereferences element name', ->
    assert.deepEqual expected, dereferenced

# Reset for other tooling like coverage!
process.chdir '..'
