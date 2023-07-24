module GraphQL
  module Types
    class Card < BaseObject
      field :id, Integer, "unique numerical identifier", null: true
      field :type, Card, "card type", null: false
      field :name, String, "name that is unique across all cards", null: false
      field :linkname, String, "url-friendly name variant", null: false
      field :created_at, Types::ISO8601DateTime, "when created", null: true
      field :updated_at, Types::ISO8601DateTime, "when last updated", null: true
      field :creator, Card, "User who created", null: true
      field :updater, Card, "User who last updated", null: true
      field :left, Card, "left name", null: true
      field :right, Card, "right name", null: true
      field :content, String, "core view of card rendered in text format", null: true

      def type
        object.type_id.card
      end

      def linkname
        object.name.url_key
      end

      def left
        object.left_id.card
      end

      def right
        object.right_id.card
      end

      def content
        object.format(:text).render_core
      end

      def creator
        object.creator_id.card
      end

      def updater
        object.updater_id.card
      end

      # support methods (move to module?)
      def referers type, field
        ::Card.search type: type, limit: 10, right_plus: [field, refer_to: object.card_id]
      end
    end
  end
end
