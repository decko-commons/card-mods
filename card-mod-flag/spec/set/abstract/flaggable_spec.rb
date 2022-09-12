RSpec.describe Card::Set::Abstract::Flaggable do
  describe "#count_open_flags" do
    def flag_subject status="open"
      Card.create! type: :flag, fields: {
        subject: card_subject.name,
        status: status,
        flag_type: "Other Problem",
        discussion: "me like cookie. you?"
      }
    end

    it "is 0 if no flags created" do
      expect(card_subject.count_open_flags).to eq(0)
    end

    it "counts any flag not marked closed" do
      flag_subject
      expect(card_subject.count_open_flags).to eq(1)
    end

    it "does not count any flag marked closed" do
      flag_subject "closed"
      expect(card_subject.count_open_flags).to eq(0)
    end
  end
end
