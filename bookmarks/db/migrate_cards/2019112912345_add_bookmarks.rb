# -*- encoding : utf-8 -*-

class AddBookmarks < Card::Migration
  def up
    ensure_code_card "Bookmarks"
    ensure_code_card "Bookmarkers"
    Card.search right: :upvotes do |vote_card|
      vote_card.update! name: Card::Name[vote_card.name.left, :bookmarks]
    end
    Card[:metric_voter].update! name: "Metric Bookmarker", codename: "metric_bookmarker"
  end
end
