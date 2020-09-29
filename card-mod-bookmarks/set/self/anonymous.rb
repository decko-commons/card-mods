# card_accessor :bookmarks, type: SessionID
# accessor wasn't working, because
#

def bookmarks_card
  @bookmarks_card ||= fetch(:bookmarks, new: { type_id: Card::SessionID })
end
