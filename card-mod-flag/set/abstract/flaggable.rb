def open_flag_cards
  new? ? [] : Card.search(open_flag_cql)
end

def count_open_flags
  new? ? 0 : Card.search(open_flag_cql.merge(return: :count))
end

private

def open_flag_cql
  { type: :flag,
    right_plus: [:subject, refer_to: id],
    not: { right_plus: [:status, { eq: "closed" }] } }
end
