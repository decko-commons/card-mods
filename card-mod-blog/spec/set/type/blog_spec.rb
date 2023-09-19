RSpec.describe Card::Set::Type::Blog do
  context "when getting and setting attributes" do
    def card_subject
      Card.create! type: "Blog", name: "My Blog", fields: {
        description: "This is a blog post description.",
        date: Date.today.to_s
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

    it "should get and set the date attribute" do
      card = card_subject

      expect(card.date).to eq(Date.today.to_s)

      card.date = Date.parse("02/02/23")
      card.save!

      expect(Date.parse(card.date)).to eq(Date.parse("02/02/23"))
    end
  end
end
