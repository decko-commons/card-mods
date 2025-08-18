RSpec.describe Card::Set::All::Alias do
  let(:simple_card) { Card["T"] }
  let(:original_name) { "T" }
  let(:new_name) { "TT" }

  describe "event: create_alias_upon_rename" do
    specify do
      simple_card.update! name: new_name, trigger: :create_alias_upon_rename
      source = Card[original_name]
      expect(source.type_code).to eq(:alias)
      expect(source.target_name).to eq(new_name)
    end
  end

  describe "event: delete_alias_upon_delete" do
    specify do
      Card.create! name: "TT", type: :alias, content: "T"
      simple_card.delete!
      expect("TT".card).to be_nil
    end
  end

  describe "#auto_alias_checkbox" do
    specify do
      expect_view(:name_form).to have_tag(".auto-alias")
    end
  end
end
