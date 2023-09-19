RSpec.describe Card::Set::Type::Blog do
  context "when getting and setting attributes" do
    def card_subject
      Card.create! type: "Blog", name: "My Blog", fields: {
        description: "This is a blog post description.",
        date: "DD/MM/YY"
      }
    end
    check_views_for_errors

    it "should get and set the description attribute" do
      card = card_subject

      expect(card.description).to eq("This is a blog post description.")

      card.description = "This is a new description."
      card.save!

      expect(card.description).to eq("This is a new description.")
    end
  end
end
