`thru` transform for JSON
-------------------------

```shell
npm install json-parser-transform
```

```javascript
json = require('json-parser-transform')
selector = (prefix) => prefix.length === 2 && prefix[0] === 'numbers'

stream
.thru(json.thru(selector))
.on('data', ({prefix,value}) => … )
```

The selector function is provided the current path in the JSON object, and must return true if you wish to collect data starting at that location.

Notice how the selector function in the example expect the prefix length to be 2; it would match the prefixes in
```json
{
  "numbers": [
    "one",
    "two",
    "three"
  ]
}
```
where the prefixes would be `["numbers",0]`, `["numbers",1]`, `["numbers",2]`; the stream would emit values `"one"`, `"two"`, `"three"`.

Notice how a basic text-based selector can be written as:

```
basic_selector = (text) => (prefix) => prefix.join('.') === text

stream
.thru(json.thru(basic_selector("friend.name")))
```

Note: it is not possible to capture using `prefix.length === 0`, because it will never get called at that point. (There wouldn't be much point in streaming the data in that case either.)
