# Generate default values based on an element type and its path in the
# element tree. This method tries to be smart about generating a sample data
# structure that makes sense when no samples or defaults were given.
faker = require 'faker/locale/en'

endsWith = (input, search) ->
  if not input then return false
  position = input.length - search.length
  lastIndex = input.indexOf search, position
  lastIndex isnt -1 and lastIndex is position

module.exports = (refract, path) ->
  last = path.length - 1
  switch refract.element
    when 'boolean' then faker.random.boolean()
    when 'number'
      switch path[last]
        when 'cost', 'price' then parseFloat(faker.finance.amount())
        else faker.random.number()
    when 'string'
      # Here we try to guess what sort of string makes sense to provide
      # rich generated examples when possible.
      switch path[last]
        when 'id', 'uid', 'uuid' then faker.random.uuid()
        when 'firstname' then faker.name.firstName()
        when 'lastname' then faker.name.lastName()
        when 'name'
          if path.length > 1 and path[last - 1] in ['user', 'userinfo',
            'customer', 'account', 'client']
              faker.name.findName()
          else if path.length > 1 and path[last - 1] in ['company', 'business']
            faker.company.companyName()
          else
            faker.lorem.words(1)
        when 'username' then faker.internet.userName()
        when 'email' then faker.internet.email()
        when 'url', 'uri', 'href', 'host', 'hostname', 'website'
          faker.internet.url()
        when 'password', 'pass' then faker.internet.password()
        when 'image', 'avatar' then faker.image.image()
        when 'address', 'location', 'street' then faker.address.streetAddress()
        when 'city' then faker.address.city()
        when 'state' then faker.address.stateAbbr()
        when 'country' then faker.address.countryCode()
        when 'zip', 'zipcode' then faker.address.zipCode()
        when 'lat', 'latitude' then faker.address.latitude()
        when 'lng', 'longitude' then faker.address.longitude()
        when 'date', 'datetime', 'timestamp' then faker.date.past()
        when 'cost', 'price' then faker.finance.amount()
        when 'currency' then faker.finance.currencyCode()
        else
          if endsWith(path[last], 'date') or endsWith(path[last], 'datetime') or
            endsWith(path[last], 'timestamp')
              faker.date.past()
          else
            faker.lorem.words()
