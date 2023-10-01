<!--
# @title README - mod: filter
-->

# Filter mod

This mod provides a framework for enhancing card searches with advanced filtering
interfaces. 

Include the Abstract::Filter set in any search set to add both:

- a `filter_form` view with progressive disclosure filter accordions inside an offcanvas, 
  and
- a `compact_filter_form` view that opens compact filter interfaces in place above search
  results.

The mod also adds support for a `filtered_list` view of list/pointer cards that makes it
easier to choose list items from options too numerous or complicated to fit into a 
standard dropdown.

### Filter maps

Filters for a given set can be specified with the `#filter_map` method, which should
return a list of filter configurations. Each configuration can be a Symbol or a Hash.
For example, here is a simple configuration with three filters.

```
def filter_map 
  [name topic bookmark]
end
```

For each filter you can use methods to define:
  1. labels, eg `#filter_topic_label` (same as the filter key if not defined)
  2. options, eg `#filter_topic_options` (empty by default)
  3. a default value, eg `#filter_topic_default` (blank unless specified), and
  4. a type, eg `#filter_topic_type` (defaults to text).

Type options include:

  - text
  - autocomplete
  - radio
  - check
  - select
  - multiselect
  - range

It is also possible to write custom filter types in the following manner:

```
def filter_myfield_type
  :my_custom_type
end  

def my_custom_type_filter
  # returns filter ui
end
```

Note that fields that use radio and check filtering in the `filter_form` view will use 
select and multiselect filtering respectively in the `compact_filter_form` view.

### Filter introspection

The full filter mapping for a given search card can be accessed via the `#filter_map`
method. A simpler list of the available keys are available at `#filter_keys`. And
the option values for any give filter are available using 
`#filter_option_values(filter_key)`.

### Contributing

Bug reports, feature suggestions requests are welcome on GitHub at 
https://github.com/wikirate/wikirate/issues.

### 🎉 Acknowledgements

The development of this module was supported by [NLnet foundation](https://nlnet.nl/).

![Image](https://nlnet.nl/logo/banner-160x60.png)
