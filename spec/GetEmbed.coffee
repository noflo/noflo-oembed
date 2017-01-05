noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-oembed'

describe 'GetEmbed component', ->
  c = null
  ins = null
  token = null
  out = null
  error = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'oembed/GetEmbed', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      token = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.inPorts.token.attach token
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    error = noflo.internalSocket.createSocket()
    c.outPorts.error.attach error
  afterEach ->
    c.outPorts.out.detach out
    c.outPorts.error.detach error
  describe 'reading a Flickr URL', ->
    it 'should produce embed data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'photo'
        chai.expect(data.title).to.equal 'Menengai crater'
        chai.expect(data.url).not.be.to.empty
        done()
      ins.send 'http://www.flickr.com/photos/bergie/5293597184/in/set-72157601512952655'
      ins.disconnect()
  describe 'reading an invalid URL', ->
    it 'should send an error', (done) ->
      error.on 'data', (data) ->
        chai.expect(data).to.be.an 'error'
      ins.send 'http://example.net/foo/bar/baz'
      ins.disconnect()
  describe 'reading a valid URL without oEmbeds', ->
    it 'should send an error', (done) ->
      error.on 'data', (data) ->
        chai.expect(data).to.be.an 'error'
      ins.send 'http://bergie.iki.fi/'
      ins.disconnect()
