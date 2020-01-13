# -*- encoding : utf-8 -*-

describe Card::Set::Self::VotedUp do 
  before do
    Card::Auth.signin "Joe Admin"
    @topic = create_topic "another voting topic"
    @card = @topic.vote_count_card
    Card['Joe User'].follow '*all', '*voted up'
    Card::Auth.signin "Joe User"
  end
  
  describe "follow upvoted card" do
    subject { 
      @topic.follower_names
    }
    context "when not voted" do
      it { is_expected.not_to include("Joe User")}
    end 
    context "when upvoted by Joe User" do
      before do
        Card::Auth.as_bot { @card.vote_up }
      end
      it { is_expected.to include("Joe User")}
    end
    context "when downvoted by Joe User" do
      before do
        Card::Auth.as_bot { @card.vote_down }
      end
      it { is_expected.not_to include("Joe User")}
    end
  end
end