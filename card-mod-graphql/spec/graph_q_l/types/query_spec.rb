RSpec.describe GraphQL::Types::Query do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]
  end

  def query_string root_field
    <<-GRAPHQL
      query {
        #{root_field} {
          name
        }
      }
    GRAPHQL
  end

  describe "card field" do
    it "finds a card by id and returns name name" do
      query = query_string "card(id: #{:search_type.card_id})"
      expect(result(query).dig("card","name")).to eq("Search")
    end
  end

  describe "cards field" do
    it "finds cards with matching names" do
      query = query_string 'cards(name: "Sign up")'
      expect(result(query)["cards"].first["name"]).to match(/Sign up/i)
    end
  end
end
