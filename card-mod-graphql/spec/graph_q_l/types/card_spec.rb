RSpec.describe GraphQL::Types::Query do
  def result name, *fields
    query = query_string name, fields
    GraphQL::CardSchema.execute(query)["data"]["card"].dig(*fields)
  end

  def query_string name, fields
    <<-GRAPHQL
      query {
        card(name: "#{name}") {
          #{query_field fields}
        }
      }
    GRAPHQL
  end

  def query_field fields
    fields.size == 1 ? fields.first : "#{fields.first} { #{fields.last} }"
  end

  describe "card: linkname field" do
    it "returns url-friendly string" do
      expect(result("Joe Admin", "linkname")).to eq("Joe_Admin")
    end
  end

  describe "card: id field" do
    it "returns integer" do
      expect(result("Joe Admin", "id")).to be_a(Integer)
    end
  end

  describe "card: type field" do
    it "returns cardtype card" do
      expect(result("Joe Admin", "type", "name")).to eq("User")
    end
  end

  describe "card: created_at field" do
    it "returns iso8601" do
      expect(DateTime.parse result("Joe Admin", "createdAt")).to be_a(DateTime)
    end
  end

  describe "card: updated_at field" do
    it "returns iso8601" do
      expect(DateTime.parse result("Joe Admin", "updatedAt")).to be_a(DateTime)
    end
  end

  describe "card: left field" do
    it "returns left card" do
      expect(result("A+B", "left", "name")).to eq("A")
    end
  end

  describe "card: right field" do
    it "returns right card" do
      expect(result("A+B", "right", "name")).to eq("B")
    end
  end

  describe "card: content field" do
    it "returns rendered text content" do
      expect(result("B", "content")).to eq("Beta Z")
    end
  end
end
