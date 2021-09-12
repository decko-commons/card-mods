RSpec.describe GraphQL::Types::Query do
  def result name, field
    query = query_string name, field
    GraphQL::CardSchema.execute(query)["data"]["card"][field]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        card(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  describe "card: type field" do
    it "finds a card by id and returns name name" do
      expect(result("Joe Admin", "linkname")).to eq("Joe_Admin")
    end
  end

  describe "cards field" do
    it "finds cards with matching names" do
      query = query_string 'cards(name: "Topic")'
      expect(result(query)["cards"].first["name"]).to match(/topic/i)
    end
  end
end
