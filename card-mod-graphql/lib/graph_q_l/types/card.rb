module GraphQL
  module Types
    class Card < BaseObject

      class << self
        def subcardtype_field fieldname, type, codename = nil
          codename ||= fieldname
          plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym

          plural_field plural_fieldname, codename, type

          define_method plural_fieldname do |limit: 10, offset: 0, **filter|
            filter[object.type.card.codename] = object.name
            card_search codename, limit, offset, filter
          end
        end

        def plural_field fieldname, codename, type
          field fieldname, [type], null: false do
            argument :limit, Integer, required: false
            argument :offset, Integer, required: false

            codename.card.format.filter_keys.each do |filter|
              argument filter, String, required: false
            end
          end
        end

        def default_limit
          10
        end

        def default_offset
          0
        end
      end

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

      def card_search codename, limit, offset, filter
        cql = codename.card.format.filter_class.new(filter).to_cql
        cql[:limit] = limit
        cql[:offset] = offset
        cql[:type_id] = codename.card.id
        ::Card.search cql
      end

    end
  end
end
