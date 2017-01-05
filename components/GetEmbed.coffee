noflo = require 'noflo'
oembed = require 'oembed'

exports.getComponent = ->
  c = new noflo.Component
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
    if c.params.token
      oembed.EMBEDLY_KEY = c.params.token
    oembed.fetch url, {}, (err, embed) =>
      return callback err if err
      @outPorts.out.beginGroup url
      @outPorts.out.send embed
      @outPorts.out.endGroup()
      callback()
