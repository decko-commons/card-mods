# -*- encoding : utf-8 -*-

describe Card::Set::Self::Voted do 
  before do
    Card::Auth.current_id = Card['Joe Admin'].id
    @claim = create_claim "another voting claim"
    @card = @claim.vote_count_card
    Card['Joe User'].follow '*all', '*voted up'
    Card::Auth.current_id = Card['Joe User'].id
  end
  
  
  describe "follow card I voted for" do
    subject { 
      @claim.follower_names
    }
    context "when not voted" do
      it { is_expected.not_to include("Joe User")}
    end 
    context "when upvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_up }
        Card.follow_caches_expired
      end
      it { is_expected.to include("Joe User")}
    end
    context "when downvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_down }  
      end
      it { is_expected.not_to include("Joe User")}
    end
  end
end