digit       [0-9]
hexa        [0-9a-fA-F]
hexa4       {hexa}{hexa}{hexa}{hexa}
acceptable  [^"\\\u0000-\u000f]
integer     (0|[1-9]{digit}*)
frac        \.{digit}+
exponent    [eE][-+]?{digit}+
number      -?{integer}{frac}?{exponent}?
%%
[{}:,\[\]]  return `'${this.text}'`
true        return 'TRUE'
false       return 'FALSE'
"           this.begin('string'); this.yy.string = ''
[ \t\r\n]   /* ignore whitespace */
{number}    return 'NUMBER'
<string>\\"           this.yy.string += '"'
<string>\\\\          this.yy.string += '\\'
<string>\\/           this.yy.string += '/'
<string>\\b           this.yy.string += '\u0008'
<string>\\f           this.yy.string += '\u000c'
<string>\\n           this.yy.string += '\u000a'
<string>\\r           this.yy.string += '\u000d'
<string>\\t           this.yy.string += '\u0009'
<string>\\u{hexa4}    this.yy.string += String.fromCodePoint(parseInt(this.text.slice(1),16))
<string>{acceptable}  this.yy.string += this.text
<string>"             this.text = this.yy.string; this.pop(); return 'STRING'
