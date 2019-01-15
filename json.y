%{

/* A parser that collects data for a given object prefix */

/* Common parts */

let top = (a) => a.length > 0 && a[a.length-1]
let truth = (x) => !!x

var collect = []
var prefix = []

let collect_data = function (value = true) {
  return collect.some(truth) ? value : undefined
}

let collect_func = function (func) {
  return collect.some(truth) ? func() : undefined
}

let enter = function (name) {
  prefix.push(name)
  collect.push(prefix_emit(prefix))
}

let next = function () {
  enter(leave()+1)
}

let leave = function () {
  collect.pop()
  return prefix.pop()
}

let send = function (value) {
  if(top(collect)) {
    emit({prefix:prefix.slice(),value})
  }
}

let object = function (key,value) {
  let x = new Object()
  x[key] = value
  return x
}

%}

%%

start
  : value
  ;

value
  : object   { $$ = $1 }
  | array    { $$ = $1 }
  | NUMBER   { $$ = parseFloat($1) }
  | STRING   { $$ = $1 }
  | TRUE     { $$ = true }
  | FALSE    { $$ = false }
  | NULL     { $$ = null }
  ;


object
  : '{' '}'        { $$ = collect_data({}) }
  | '{' pairs '}'  { $$ = collect_data($2) }
  ;

pairs
  : pair           { $$ = collect_data($1) }
  | pairs ',' pair { $$ = collect_func( () => Object.assign($1,$3) ) }
  ;

pair
  : key ':' value  { $$ = collect_func( () => object($1,$3) ); send($3); leave() }
  ;
key
  : STRING         { enter($1); $$ = $1 }
  ;

array
  : '[' ']'                 { $$ = collect_data([]) }
  | start_array values ']'  { $$ = collect_data($2); leave() }
  ;

start_array
  : '['              { enter(0) }
  ;

values
  : value            { $$ = collect_data([$1]);                 send($1); next() }
  | values ',' value { $$ = collect_data( () => $1.concat($3)); send($3); next() }
  ;

