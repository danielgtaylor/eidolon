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

# Reset for other tooling like coverage!
process.chdir '..'
