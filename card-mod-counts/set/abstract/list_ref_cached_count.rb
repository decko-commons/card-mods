# Include with options :type_to_count and :tag
# counts all cards of a type "type_to_count" that are tagged with self via a
# +<list_field> pointer.
# If <type_to_count>+<list_field> card is updated, all
# <changed item name>+<type_to_count> cached counts are updated
#
# @example count for topic cards the metrics that are tagged with the topic
# via a +topic card
#   include_set Abstract::ListRefCachedCount, type_to_count: :metric,
#                                             list_field: :topic

include_set Abstract::SearchCachedCount

def self.included host_class
  host_class.class_eval do
    include_set Abstract::CachedCount
    recount_trigger :type_plus_right,
                    host_class.type_to_count,
                    host_class.list_field do |changed_card|
      field_code = host_class.try(:count_field) || host_class.type_to_count

      changed_card.changed_item_names.map do |item_name|
        Card.fetch item_name.to_name.field(field_code)
      end
    end

    define_method :type_id_to_count do
      Card::Codename.id host_class.type_to_count
    end

    define_method :list_field_id do
      Card::Codename.id host_class.list_field
    end
  end
end

def cql_content
  { type_id: type_id_to_count, right_plus: right_plus_val }
end

def right_plus_val
  [list_field_id, { refer_to: left.id }]
end

format do
  # TODO: make less hacky.
  # Without this filter cql can overwrite right_plus
  def filter_cql
    cql = super
    cql[:right_plus] = [cql[:right_plus], card.right_plus_val].compact
    cql
  end
end
