    ({expect} = require 'chai').should()
    Express = require 'express'
    Request = require 'superagent'

    describe 'The module', ->
      it 'should load', ->
        require '..'

      app = Express()
      app.get '/', (req,res) ->
        res.json [hello:'world']
      app.get '/null', (req,res) ->
        res.json [hello:null]
      app.get '/numbers', (req,res) ->
        res.json numbers: ['one','two','three']
      app.get '/newline', (req,res) ->
        res.send (JSON.stringify [hello:'word'], null, '  ').replace(/\n/g,'\r\n')
      app.get '/funky', (req,res) ->
        res.send (JSON.stringify content: {
          funk1: 'string'
          funk2: true
          funk3: false
          funk4: null
          funk5: 0
          funk6: 182
          funk7: 12.73
          funk8: [1,2,81]
          funk9: a:3,b:'ok'
        }, null, '  ').replace(/\n/g,'\r\n')
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

      it 'should parse null', (done) ->
        m = require '..'

        thru = m.thru (prefix) ->
          prefix.length is 1 and prefix[0] is 0
        thru Request.get 'http://127.0.0.1:3000/null'
        .on 'data', ({prefix,value}) ->
          expect(value).to.have.property 'hello', null
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

      it 'should parse funky', (done) ->
        m = require '..'

        thru = m.thru (prefix) ->
          prefix.length is 1 and prefix[0] is 'content'
        thru Request.get 'http://127.0.0.1:3000/funky'
        .on 'data', ({prefix,value}) ->
          expect(value).to.have.property 'funk1', 'string'
          expect(value).to.have.property 'funk2', true
          expect(value).to.have.property 'funk3', false
          expect(value).to.have.property 'funk4', null
          expect(value).to.have.property 'funk5', 0
          expect(value).to.have.property 'funk6', 182
          expect(value).to.have.property 'funk7', 12.73
          expect(value).to.have.property 'funk8'
          expect(value.funk8).to.have.length 3
          expect(value.funk8[0]).to.eql 1
          expect(value.funk8[1]).to.eql 2
          expect(value.funk8[2]).to.eql 81
          expect(value).to.have.property 'funk9'
          expect(value.funk9).to.have.property 'a', 3
          expect(value.funk9).to.have.property 'b','ok'
          done()
