RSpec.describe Card::Set::Type::Blog do
  context "when getting and setting attributes" do
    def card_subject
      Card.create! type: "Blog", name: "My Blog", fields: {
        description: "This is blog post description.",
        date: "01/01/23"
      }
    end
    
    check_views_for_errors

    it "renders the correct description" do
      blog_card = card_subject
      expect(blog_card.description).to eq("This is blog post description.")
    end

    it "renders the correct date" do
      blog_card = card_subject
      expect(blog_card.date).to eq("01/01/23")
    end
  end
end
