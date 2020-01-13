RSpec.describe Card::Set::Right::Account do
  context "with bookmarks in session" do
    let(:dummy_account_args) do
      {
        name: "BookmarkUser",
        type_id: Card::SignupID,
        "+*account" => {
          "+*email" => "tmpuser@wagn.org",
          "+*password" => "tmp_pass"
        }
      }
    end

    before do
      Card::Auth.signin Card::AnonymousID
      bm = Card::Bookmark.current_list_card
      bm.add_item "A"
    end

    it "should copy and save bookmarks from session" do
      user = Card.create! dummy_account_args
      expect(user.bookmarks_card.item_names.first).to eq("A")
    end
  end
end
