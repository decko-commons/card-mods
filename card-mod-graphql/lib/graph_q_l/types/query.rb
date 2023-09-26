module GraphQL
  module Types
    class Query < BaseObject
      # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
      # include Types::Relay::HasNodeField
      # include Types::Relay::HasNodesField

      # Add root-level fields here.
      # They will be entry points for queries on your schema.

      field :card, Card, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end

      field :cards, [Card], null: false do
        argument :name, String, required: false
        argument :type, String, required: false
      end

      def card **mark
        ok_card nil, **mark
      end

      def cards name: nil, type: nil, limit: 10, offset: 0
        card_search name, type, limit, offset
      end

      private

      def ok_card_of_type type_code, **mark
        card = ok_card(**mark)
        card if card.type_code == type_code
      end

      def ok_card type_code, name: nil, id: nil
        card = ::Card.fetch name || id
        card if card&.ok?(:read) && (!type_code || card.type_code == type_code)
      end

      def card_search name, type, limit, offset
        cql = { limit: limit, offset: offset }
        cql[:type] = type if type
        cql[:name] = [:match, name] if name
        ::Card.search cql
      end
    end
  end
end
