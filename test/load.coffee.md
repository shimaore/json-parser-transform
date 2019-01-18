    ({expect} = require 'chai').should()
    Express = require 'express'
    Request = require 'superagent'

    describe 'The module', ->
      it 'should load', ->
        require '..'

      app = Express()
      app.get '/', (req,res) ->
        res.json [hello:'world']
      app.get '/numbers', (req,res) ->
        res.json numbers: ['one','two','three']
      app.get '/newline', (req,res) ->
        res.send (JSON.stringify [hello:'word'], null, '  ').replace(/\n/g,'\r\n')
      server = app.listen 3000
      after ->
        server.close()

      it 'should parse', (done) ->
        m = require '..'

        thru = m.thru (prefix) ->
          prefix.length is 1 and prefix[0] is 0
        thru Request.get 'http://127.0.0.1:3000'
        .on 'data', ({prefix,value}) ->
          expect(value).to.have.property 'hello', 'world'
          done()

      it 'should process the example in README', (done) ->
        m = require '..'

        thru = m.thru (prefix) ->
          prefix.length is 2 and prefix[0] is 'numbers'
        count = 0
        thru Request.get 'http://127.0.0.1:3000/numbers'
        .on 'data', ({prefix,value}) ->
          expect(value).to.be.oneOf ['one','two','three']
          done() if ++count is 3

      it 'should parse multiline', (done) ->
        m = require '..'

        thru = m.thru (prefix) ->
          prefix.length is 1 and prefix[0] is 0
        thru Request.get 'http://127.0.0.1:3000/newline'
        .on 'data', ({prefix,value}) ->
          expect(value).to.have.property 'hello', 'word'
          done()
