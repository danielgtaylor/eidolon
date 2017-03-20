eidolon = require '../src/eidolon'
dereference = require '../src/dereference'
{expect} = require 'chai'
faker = require 'faker/locale/en'
fs = require 'fs'
glob = require 'glob'
path = require 'path'
sinon = require 'sinon'

{defaultValue, Eidolon} = eidolon

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

    instance = new Eidolon structures

    it 'Generates an example', ->
      expected = require filename.replace(/-refract\.json/, '-example.json')
      example = instance.example input
      expect(example).to.deep.equal(expected)

    it 'Generates a schema', ->
      expected = require filename.replace(/-refract\.json/, '-schema.json')
      schema = instance.schema input
      expect(schema).to.deep.equal(expected)

describe 'Defaults', ->
  refract =
    element: 'object'
    content: [
        element: 'member'
        content:
          key:
            element: 'string'
            content: 'one'
      ,
        element: 'member'
        content:
          key:
            element: 'string'
            content: 'two'
          value:
            element: 'number'
    ]

  example = null

  before ->
    example = eidolon.example refract

  it 'treats a member with no value as a string', ->
    expect(example.one).to.be.a('string')

  it 'generates a value if there is no content', ->
    expect(example.two).to.be.a('number')

describe 'Dereferencing', ->
  refract =
    element: 'MyType'
    content: [
      element: 'member'
      content:
        key:
          element: 'string'
          content: 'bar2'
        value:
          element: 'number'
          content: 5
    ]

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
        ,
          element: 'member'
          content:
            key:
              element: 'string'
              content: 'bar2'
            content:
              element: 'string'
      ]

  expected =
    element: 'object'
    meta:
      ref: 'MyType'
      links: [
        {
          relation: 'origin'
          href: 'http://refract.link/inherited/'
        }
      ]
    content: [
        element: 'member'
        meta:
          ref: 'MyType'
          links: [
            {
              relation: 'origin'
              href: 'http://refract.link/inherited-member/'
            }
          ]
        content:
          key:
            element: 'string'
            content: 'foo'
          value:
            element: 'number'
            meta:
              ref: 'FooType'
              links: [
                {
                  relation: 'origin'
                  href: 'http://refract.link/inherited/'
                }
              ]
            content: 5
      ,
        element: 'member'
        meta:
          ref: 'BarType'
          links: [
            {
              relation: 'origin'
              href: 'http://refract.link/included-member/'
            }
          ]
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
            content: 'bar2'
          value:
            element: 'number'
            content: 5
      ,
        element: 'member'
        meta:
          ref: 'MyType'
          links: [
            {
              relation: 'origin'
              href: 'http://refract.link/inherited-member/'
            }
          ]
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
    expect(dereferenced).to.deep.equal(expected)

describe 'Dereferencing an empty ‘Include’', ->
  refract = {
    element: 'object',
    meta: {
      id: 'TreeItem3'
    },
    content: [
      {
        element: 'ref',
        content: {
          href: '',
          path: 'content',
        }
      }
    ]
  }

  eidolon = new Eidolon([])
  dereferenced = eidolon.dereference(refract)

  it 'Dereferences element name', ->
    expect(dereferenced).to.deep.equal(refract)

describe 'Dereferencing a data structure with sourcemaps', ->
  refract = {
    element: 'array',
    meta: {
      id: {
        element: 'string',
        content: 'A'
      }
    },
    content: [
      {
        element: 'A'
      }
    ]
  }

  it 'Dereferences element name', ->
    dereferenced = dereference(refract, {})
    expect(dereferenced.content).to.have.lengthOf(1)
    expect(dereferenced.content[0].meta.links).to.have.lengthOf(1)

describe 'Dereferencing a data structure with sourcemaps when it is known', ->
  refract = {
    element: 'object',
    meta: {
      id: {
        element: 'string',
        content: 'A'
      }
    },
    content: []
  }

  it 'should contain links', ->
    dereferenced = dereference(refract, {}, ['A'])
    expect(dereferenced.meta.links).to.have.lengthOf(1)

describe 'Defaults', ->
  beforeEach ->
    faker.seed(1)

  it 'can generate a boolean', ->
    expect(defaultValue {element: 'boolean'}, []).to.be.a('boolean')

  it 'can generate a number', ->
    expect(defaultValue {element: 'number'}, []).to.be.a('number')

  it 'can generate a random string', ->
    sinon.spy faker.lorem, 'words'
    defaultValue {element: 'string'}, []
    expect(faker.lorem.words.called).to.be.true
    faker.lorem.words.restore()

  it 'can generate a unique ID', ->
    sinon.spy faker.random, 'uuid'
    expect(defaultValue {element: 'string'}, ['id']).to.match(
      /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
    expect(faker.random.uuid.called).to.be.true
    faker.random.uuid.restore()

  it 'can generate a first name', ->
    sinon.spy faker.name, 'firstName'
    defaultValue {element: 'string'}, ['firstname']
    expect(faker.name.firstName.called).to.be.true
    faker.name.firstName.restore()

  it 'can generate a last name', ->
    sinon.spy faker.name, 'lastName'
    defaultValue {element: 'string'}, ['lastname']
    expect(faker.name.lastName.called).to.be.true
    faker.name.lastName.restore()

  it 'can generate a customer name', ->
    sinon.spy faker.name, 'findName'
    defaultValue {element: 'string'}, ['user', 'name']
    expect(faker.name.findName.called).to.be.true
    faker.name.findName.restore()

  it 'can generate a company name', ->
    sinon.spy faker.company, 'companyName'
    defaultValue {element: 'string'}, ['company', 'name']
    expect(faker.company.companyName.called).to.be.true
    faker.company.companyName.restore()

  it 'can generate some other name', ->
    sinon.spy faker.lorem, 'words'
    defaultValue {element: 'string'}, ['widget', 'name']
    expect(faker.lorem.words.called).to.be.true
    faker.lorem.words.restore()

  it 'can generate a username', ->
    sinon.spy faker.internet, 'userName'
    defaultValue {element: 'string'}, ['username']
    expect(faker.internet.userName.called).to.be.true
    faker.internet.userName.restore()

  it 'can generate an email', ->
    sinon.spy faker.internet, 'email'
    defaultValue {element: 'string'}, ['email']
    expect(faker.internet.email.called).to.be.true
    faker.internet.email.restore()

  it 'can generate a URL', ->
    sinon.spy faker.internet, 'url'
    defaultValue {element: 'string'}, ['url']
    expect(faker.internet.url.called).to.be.true
    faker.internet.url.restore()

  it 'can generate a random password', ->
    sinon.spy faker.internet, 'password'
    defaultValue {element: 'string'}, ['password']
    expect(faker.internet.password.called).to.be.true
    faker.internet.password.restore()

  it 'can generate an avatar URL', ->
    sinon.spy faker.image, 'image'
    defaultValue {element: 'string'}, ['user', 'avatar']
    expect(faker.image.image.called).to.be.true
    faker.image.image.restore()

  it 'can generate a street address', ->
    sinon.spy faker.address, 'streetAddress'
    defaultValue {element: 'string'}, ['address']
    expect(faker.address.streetAddress.called).to.be.true
    faker.address.streetAddress.restore()

  it 'can generate a city', ->
    sinon.spy faker.address, 'city'
    defaultValue {element: 'string'}, ['city']
    expect(faker.address.city.called).to.be.true
    faker.address.city.restore()

  it 'can generate a state', ->
    sinon.spy faker.address, 'stateAbbr'
    defaultValue {element: 'string'}, ['state']
    expect(faker.address.stateAbbr.called).to.be.true
    faker.address.stateAbbr.restore()

  it 'can generate a zip code', ->
    sinon.spy faker.address, 'zipCode'
    defaultValue {element: 'string'}, ['zip']
    expect(faker.address.zipCode.called).to.be.true
    faker.address.zipCode.restore()

  it 'can generate a country code', ->
    sinon.spy faker.address, 'countryCode'
    defaultValue {element: 'string'}, ['country']
    expect(faker.address.countryCode.called).to.be.true
    faker.address.countryCode.restore()

  it 'can generate a latitude position', ->
    sinon.spy faker.address, 'latitude'
    defaultValue {element: 'string'}, ['lat']
    expect(faker.address.latitude.called).to.be.true
    faker.address.latitude.restore()

  it 'can generate a longitude position', ->
    sinon.spy faker.address, 'longitude'
    defaultValue {element: 'string'}, ['lng']
    expect(faker.address.longitude.called).to.be.true
    faker.address.longitude.restore()

  it 'can generate a date', ->
    sinon.spy faker.date, 'past'
    defaultValue {element: 'string'}, ['date']
    expect(faker.date.past.called).to.be.true
    faker.date.past.restore()

  it 'can generate a date when a member ends with `date`', ->
    sinon.spy faker.date, 'past'
    defaultValue {element: 'string'}, ['login_date']
    expect(faker.date.past.called).to.be.true
    faker.date.past.restore()

  it 'can generate a cost', ->
    sinon.spy faker.finance, 'amount'
    defaultValue {element: 'string'}, ['cost']
    expect(faker.finance.amount.called).to.be.true
    faker.finance.amount.restore()

  it 'can generate a currency', ->
    sinon.spy faker.finance, 'currencyCode'
    defaultValue {element: 'string'}, ['currency']
    expect(faker.finance.currencyCode.called).to.be.true
    faker.finance.currencyCode.restore()

# Reset for other tooling like coverage!
process.chdir '..'
