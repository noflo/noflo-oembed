noflo = require 'noflo'
request = require 'superagent'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'cloud-download'
  c.description = 'Get oEmbed information for a URL'
  c.inPorts.add 'in',
    datatype: 'string'
  c.inPorts.add 'token',
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    forwardGroups: true
    params: ['token']
    async: true
  , (url, groups, out, callback) ->
    params =
      url: url
    params.key = c.params.token if c.params.token

    request
    .get('https://api.embedly.com/1/oembed')
    .query(params)
    .end (err, res) ->
      return callback err if err
      out.beginGroup url
      out.send res.body
      out.endGroup()
      callback()
