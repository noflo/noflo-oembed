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
      if process.env.EMBEDLY_API_TOKEN
        c.inPorts.token.attach token
        token.send process.env.EMBEDLY_API_TOKEN
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
      return @skip() unless process.env.EMBEDLY_API_TOKEN
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'photo'
        chai.expect(data.title).to.equal 'Menengai crater'
        chai.expect(data.url).not.be.to.empty
        done()
      error.on 'data', done
      ins.send 'http://www.flickr.com/photos/bergie/5293597184/in/set-72157601512952655'
      ins.disconnect()
  describe 'reading an invalid URL', ->
    it 'should send an error', (done) ->
      return @skip() unless process.env.EMBEDLY_API_TOKEN
      error.on 'data', (data) ->
        chai.expect(data).to.be.an 'error'
        done()
      ins.send 'http://example.net/foo/bar/baz'
      ins.disconnect()
