readenv = require "../components/GetEmbed"
socket = require('noflo').internalSocket

setupComponent = ->
  c = readenv.getComponent()
  ins = socket.createSocket()
  token = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.in.attach ins
  c.inPorts.token.attach token
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  [c, ins, token, out, err]

exports['test reading a Flickr URL'] = (test) ->
  [c, ins, token, out, err] = setupComponent()
  test.expect 6
  out.once 'data', (data) ->
    test.ok data
    test.ok data.type
    test.equal data.type, 'photo'
    test.ok data.title
    test.equal data.title, 'Menengai crater'
    test.ok data.url

  out.once 'disconnect', ->
    test.done()

  ins.send 'http://www.flickr.com/photos/bergie/5293597184/in/set-72157601512952655'

exports['test reading an invalid URL'] = (test) ->
  [c, ins, token, out, err] = setupComponent()
  err.once 'data', (data) ->
    test.ok data
    test.done()

  ins.send 'http://example.net/foo/bar/baz'
