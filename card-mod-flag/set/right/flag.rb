assign_type :search_type

def virtual?
  new?
end

def cql_content
  { type: :flag,
    right_plus: [:subject, refer_to: "_left"] }
end
