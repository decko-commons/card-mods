<!--
# @title README - mod: logger
-->

# Logger mod (Experimental)

This experimental mod has code in support of decko-friendly performance and request 
logging. It cannot boast the sophistication or support of modern logging tools, but
there is enough clever code here to keep it around and hope that it some day may be
useful, if for nothing else than for building richer integration with more established
logging tools.

## Performance logger

To enable logging add a performance_logger hash to your configuration.

Example:

```
 config.performance_logger = {
   min_time: 100,                 # show only method calls that are slower than 100ms
   max_depth: 3,                  # show nested method calls only up to depth 3
   details: true,                 # show method arguments and sql
   methods: [:event, :search, :fetch, :view],  # choose methods to log
   log_level: :info
 }
```

 If you give :methods a hash you can log arbitrary methods. The syntax is as follows:
   class =>  method type => method name => log options

```
 Example:
   Card => {
     instance: [:fetch, :search],
     singleton: { fetch: { :title => 'Card.fetch' } },
     all: {
       fetch{
         message: 2,           # use second argument passed to fetch
         details: :to_s,       # use return value of to_s in method context
         title: proc { |method_context| method_context.name }
       },
     },
   }
```

`class`, `method type` and `log options` are optional.

Default values are `Card`, `:all`, and 
```
  { title: method name, message: first argument, details: remaining arguments }
```

For example `[:fetch]` is equivalent to 
```
  Card => { all: { fetch: { message: 1, details: 1..-1 } }
```

## Request Logger

