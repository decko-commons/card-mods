include_set Abstract::CqlSearch
include_set Abstract::SearchViews

def self.included host_class
  host_class.include_set Abstract::CachedCount
end

def virtual?
  new?
end

def type_id
  SearchTypeID
end
