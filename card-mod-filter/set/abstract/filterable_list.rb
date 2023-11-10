# Makes it so that a List can be viewed (and filtered) as a Search

include_set Abstract::CqlSearch
include_set Abstract::SearchViews

def cql_content
  { referred_to_by: "_" }
end

def item_cards args={}
  standard_item_cards args
end

def count
  item_strings.size
end

format do
  def show_paging?
    false
  end
end
