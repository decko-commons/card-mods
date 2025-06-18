include_set Abstract::CqlSearch
include_set Abstract::SearchViews

def self.included host_class
  host_class.include_set Abstract::CachedCount
  host_class.assign_type :search
end

def virtual?
  new?
end
