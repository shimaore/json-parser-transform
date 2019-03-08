The stream is first ran through utf8-stream

    utf8Stream = require 'utf8-stream'

    Stream = require 'stream'

and mapped from Buffer to strings

    class toStringTransform extends Stream.Transform
      constructor: (options = {}) ->
        options.objectMode = true
        super options
      _transform: (chunk,encoding,next) ->
        @push chunk.toString 'utf8'
        next()
        return

then through the lexer

    fs = require 'fs'
    path = require 'path'
    {LexerParser,LexerTransform,Grammar,ParserTransform} = require 'parser-transform'

    lexer  = fs.readFileSync (path.join __dirname, 'json.l'), 'utf8'
    dfas = LexerParser.parse lexer

and the parser

    parser = fs.readFileSync (path.join __dirname, 'json.y'), 'utf8'
    grammar = Grammar.fromString parser, mode:'LALR1', 'bnf'

    class JSONParserTransform extends ParserTransform
      constructor: (grammar,prefix_emit,options = {}) ->
        super grammar, options
        @parser._generator.context.prefix_emit = prefix_emit
        return

We make sure to create new instances for each stream, since they hold state!

    thru = (prefix_emit) ->
      (stream) ->
        pump(
          stream,
          utf8Stream(),
          (new toStringTransform()),
          (new LexerTransform dfas),
          (new JSONParserTransform grammar, prefix_emit)
        )

    module.exports = {JSONParserTransform,thru}
    pump = require 'pump'
