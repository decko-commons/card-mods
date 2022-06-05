RSpec.describe Card::Query::CardQuery::FullTextMatching do
  def search term, query={}
    query[:fulltext_match] = term
    Card.search query.reverse_merge(not: { right: {} }, return: :name, sort_by: :name)
  end

  specify "sort_by: name" do
    expect(search("permissions"))
      .to eq(["*account", "Administrator", "mod: permissions", "Role", "style: mods"])
  end

  xspecify "sort_by: relevance" do
    expect(search("permissions", sort_by: :relevance))
      .to eq(["*account", "Role", "Administrator", "mod: permissions"])
  end

  specify "word fragment" do
    expect(search("permiss")).to eq([])
  end
end
