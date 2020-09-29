RSpec.describe Card::Bookmark do
  describe "#ok?" do
    it "is true for joe user" do
      Card::Auth.signin "joe user"
      expect(Card::Bookmark.ok?).to be_truthy
    end

    it "is true for anonymous user" do
      Card::Auth.signin Card::AnonymousID
      expect(Card::Bookmark.ok?).to be_truthy
    end

    it "is not true for bot" do
      Card::Auth.signin Card::WagnBotID
      expect(Card::Bookmark.ok?).to be_falsey
    end
  end

  describe "#current_list_card" do
    let(:list_card) { Card::Bookmark.current_list_card }

    it "is named +bookmarks" do
      expect(list_card.name).to eq("Joe User+bookmarks")
    end

    it "is a pointer for Joe User" do
      expect(list_card.type_code).to eq(:pointer)
    end

    it "is a session for anonymous" do
      Card::Auth.signin Card::AnonymousID
      expect(list_card.type_code).to eq(:session)
    end
  end
end
