RSpec.describe Card::Set::Abstract::Bookmarkable do
  check_html_views_for_errors

  describe "#toggle_bookmark" do
    let :toggled_bookmark do
      card_subject.update! trigger: :toggle_bookmark
      Card::Bookmark.current_list_card.item_names.last
    end

    it "should trigger update to +bookmarks card" do
      expect(toggled_bookmark).to eq(card_subject.name)
    end

    it "should work for anonymous users (in session)" do
      Card::Auth.current_id = Card::AnonymousID
      expect(toggled_bookmark).to eq(card_subject.name)
    end
  end
end
