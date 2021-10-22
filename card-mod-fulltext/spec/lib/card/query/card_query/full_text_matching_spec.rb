RSpec.describe Card::Query::CardQuery::FullTextMatching do
  def search term, query={}
    query[:fulltext_match] = term
    Card.search query.reverse_merge(return: :name, sort: :name)
  end

  specify "sort: name" do
    expect(search("superhero")).to eq(["superhero skin", "theme: superhero"])
  end

  specify "sort: relevance" do
    expect(search("superhero", sort: :relevance))
      .to eq(["theme: superhero", "superhero skin"])
  end

  specify "word fragment" do
    expect(search("superh")).to eq([])
  end
end
