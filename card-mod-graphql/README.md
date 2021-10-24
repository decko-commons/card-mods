<!--
# @title README - mod: graphql
-->

# GraphQL mod (alpha)

This experimental mod supports simple GraphQL queries of decko sites.

## Setup

Once this mod is installed, you will need to add the following to 
`config/routes.rb`:

```
  post "api/graphql", to: "graphql#execute"
  mount GraphiQL::Rails::Engine, at: "api/graphiql", graphql_path: "graphql"
```

Having done so, you can point your browser to `YOUR_DECK_ROOT/api/graphiql` to
get a GraphiQL client with which you can make GraphiQL requests.
