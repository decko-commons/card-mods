RSpec.describe Card::Query::CardQuery::FullTextMatching do
  def search term, query={}
    query[:fulltext_match] = term
    Card.search query.reverse_merge(not: { right: {} }, return: :name, sort: :name)
  end

  specify "sort: name" do
    expect(search("permissions")).to eq(["Administrator", "mod: permissions"])
  end

  specify "sort: relevance" do
    expect(search("permissions", sort: :relevance))
      .to eq(["mod: permissions", "Administrator"])
  end

  specify "word fragment" do
    expect(search("permiss")).to eq([])
  end
end
