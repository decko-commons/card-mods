RSpec.describe Card::Query::CachedCountSorting do
  subject do
    Card::Query.run @query.reverse_merge return: :name, sort_by: :name
  end

  def sort args
    Card::Query.new return: :name, sort_by: args
  end

  describe "sql" do
    subject { sort(right: "A", item: "cached_count", return: "count").sql }

    it "joins with cached counts table" do
      is_expected.to include(
        "JOIN counts counts_table ON c0.id = counts_table.left_id AND "\
        "counts_table.right_id = #{'A'.card_id}"
      )
    end
    it "orders by cached counts" do
      is_expected.to include("ORDER BY CAST(counts_table.value AS signed) asc")
    end
  end
end
