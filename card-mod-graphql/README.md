<!--
# @title README - mod: graphql
-->

# GraphQL mod

This mod supports simple GraphQL queries of decko sites by defining the base Data Model and GraphQL Schema. More
specifically, the base types, queries and mutations are defined. This version of the GraphQL mod allows users to query
cards by name and type.

### Extending GraphQL mod

Everything on decko is a card, so make sure when developing your own card types and including them on GraphQL schema to
extend the `Card` class. Let's say, we have a decko site we extend to work as a blog and we create a new cardtype `blog`
and contains the subcard `author` and you want to extend your GraphQL functionality to allow users to search blogs as
well. You need to define the Blog as follows:

```ruby

module GraphQL
  module Types
    class Blog < Card
      field :author, String, null: false

      def author
        object.author
      end
    end
  end
end
```

Include blog in `GraphQL::Types::Query`
```ruby

module GraphQL
  module Types
    class Query < BaseObject
      field :blogs, Blog, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
        argument :author, String, required: false
      end

      field :blogs, [Blog], null: false do
        argument :name, String, required: false
        argument :id, Integer, required: false
        argument :author, String, required: false
      end
    end
  end
end
```

### Setting up the web client

Once this mod is installed, you will need to add the following to
`config/routes.rb`:

```
  post "api/graphql", to: "graphql#execute"
  mount GraphiQL::Rails::Engine, at: "api/graphiql", graphql_path: "graphql"
```

Having done so, you can point your browser to `YOUR_DECK_ROOT/api/graphiql` to
get a GraphiQL client with which you can make GraphiQL requests.

### Contributing

Bug reports, feature suggestions requests are welcome on GitHub at https://github.com/decko-commons/card-mods/issues.

### 🎉 Acknowledgements

The development of this module was supported by [NLnet foundation](https://nlnet.nl/).

![Image](https://nlnet.nl/logo/banner-160x60.png)