describe Card::Set::Right::VoteCount do
  before do
    Card::Auth.current_id = Card['Joe Admin'].id
    @claim = create_claim "another voting claim"
    @card = @claim.vote_count_card
    Card::Auth.current_id = Card['Joe User'].id
  end

  it 'default vote count is 1' do
    expect(@claim.vote_count.to_i).to eq 1
  end

  describe "#vote_status" do
    subject { @card.vote_status }
    context "when not voted by user" do
      it { is_expected.to eq("?") }
    end
    context "when upvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_up }
      end
      it { is_expected.to eq("+")}
    end
    context "when downvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_down }
      end
      it { is_expected.to eq("-")}
    end
    context "when not signed in" do
      subject do
        Card::Auth.current_id = Card::AnonymousID
        @card.vote_status
      end
      it { is_expected.to eq("#")}
    end
  end

  describe "#vote_up" do
    context "when voted down" do
      before do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save!
          @uvc = @claim.upvote_count.to_i
          @dvc = @claim.downvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card = @claim.vote_count_card
          @card.vote_up
          @card.save!
        end
      end
      it "decreases downvote count" do
        Card::Auth.as_bot do
          expect(@claim.downvote_count.to_i).to eq @dvc-1
        end
      end
      it "doesn't change upvote count" do
        Card::Auth.as_bot do
          expect(@claim.upvote_count.to_i).to eq @uvc
        end
      end
      it "increases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc+1
      end
    end
    context "when drag and drop the vote to middle of the list" do
      before do
        Card::Auth.current_id = Card['Joe User'].id
        Card::Auth.as_bot do
          @card.vote_up
          @card.save!

          @claim1 = create_claim "another voting claim1"
          @card1 = @claim1.vote_count_card
        end
        Card::Auth.current_id = Card['Joe Admin'].id
        Card::Auth.as_bot do
          @claim2 = create_claim "another voting claim2"
          @card2 = @claim2.vote_count_card

        end
        Card::Auth.current_id = Card['Joe User'].id
        Card::Auth.as_bot do
          @uvc = @claim2.upvote_count.to_i
          @vc = @claim2.vote_count.to_i
          @card2.vote_up @claim1.id
          @card2.save!
        end
      end
      it "shows the new voted claim to middle of the list" do
        uv_card = Card::Auth.current.upvotes_card
        vote_item_names = uv_card.item_names
        expect(vote_item_names[0]).to eq("~#{@claim.id}")
        expect(vote_item_names[1]).to eq("~#{@claim2.id}")
        expect(vote_item_names[2]).to eq("~#{@claim1.id}")
      end
    end
    context "when not voted" do
      before do
        Card::Auth.as_bot do
          @uvc = @claim.upvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card.vote_up
          @card.save!
        end
      end
      it "increases upvote count" do
        Card::Auth.as_bot do
          expect(@claim.upvote_count.to_i).to eq @uvc+1
        end
      end
      it "increases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc+1
      end
      it "increases upvote count only once" do
        Card::Auth.as_bot do
          card = @claim.vote_count_card
          card.vote_up
          card.save!
        end
        expect(@claim.upvote_count.to_i).to eq @uvc+1
      end
    end
  end
  describe "#force_neutral" do
    context "when voted up" do
      it "decrease upvote count" do
        Card::Auth.as_bot do
          @card.vote_up
          @card.save!
        end
        uvc = @claim.upvote_count.to_i
        vc = @claim.vote_count.to_i
        Card::Auth.as_bot do
          @card.force_neutral
          @card.save!
        end
        expect(@claim.upvote_count.to_i).to eq(uvc-1)
        expect(@claim.vote_count.to_i).to eq(vc-1)
      end
    end
    context "when voted down" do
      it "decrease downvote count" do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save!
        end
        uvc = @claim.downvote_count.to_i
        vc = @claim.vote_count.to_i
        Card::Auth.as_bot do
          @card.force_neutral
          @card.save!
        end
        expect(@claim.downvote_count.to_i).to eq(uvc-1)
        expect(@claim.vote_count.to_i).to eq(vc+1)
      end
    end
  end
  describe "#vote_down" do
    context "when voted up" do
      before do
        Card::Auth.as_bot do
          @card.vote_up
          @card.save!
          @uvc = @claim.upvote_count.to_i
          @dvc = @claim.downvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card = @claim.vote_count_card
          @card.vote_down
          @card.save!
        end
      end
      it "decreases upvote count" do
        Card::Auth.as_bot do
          expect(@claim.upvote_count.to_i).to eq @uvc-1
        end
      end
      it "doesn't change downvote count" do
        Card::Auth.as_bot do
          expect(@claim.downvote_count.to_i).to eq @dvc
        end
      end
      it "decreases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc-1
      end
    end
    context "when not voted" do
      before do
        Card::Auth.as_bot do
          @dvc = @claim.downvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card.vote_down
          @card.save!
        end
      end
      it "increases downvote count" do
        Card::Auth.as_bot do
          expect(@claim.downvote_count.to_i).to eq @dvc+1
        end
      end
      it "decreases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc-1
      end
      it "increases downvote count only once" do
        Card::Auth.as_bot do
          card = @claim.vote_count_card
          card.vote_down
          card.save!
        end
        expect(@claim.downvote_count.to_i).to eq @dvc+1
      end
    end
  end
  describe "event vote" do
     before do
        @vc = @claim.vote_count.to_i
      end
    context "signed in or anonymous with session_vote enabled" do
      it "votes up" do
        Card::Env.params['vote'] = "up"
        @claim.vote_count_card.update_attributes! nil
        uv_card = Card::Auth.current.upvotes_card
        vote_item_names = uv_card.item_names
        expect(vote_item_names.include?"~#{@claim.id}").to be true
        expect(@claim.vote_count.to_i).to eq @vc+1
      end
      it "votes down" do
        Card::Env.params['vote'] = "down"
        @claim.vote_count_card.update_attributes! nil
        uv_card = Card::Auth.current.downvotes_card
        vote_item_names = uv_card.item_names
        expect(vote_item_names.include?"~#{@claim.id}").to be true
        expect(@claim.vote_count.to_i).to eq @vc-1
      end
      it "votes force-up" do
        @claim.vote_count_card.vote_down
        vc = @claim.vote_count.to_i
        Card::Env.params['vote'] = "force-up"
        @claim.vote_count_card.update_attributes! nil
        uv_card = Card::Auth.current.upvotes_card
        vote_item_names = uv_card.item_names
        expect(vote_item_names.include?"~#{@claim.id}").to be true
        expect(@claim.vote_count.to_i).to eq vc+2
      end
      it "votes force-down" do
        @claim.vote_count_card.vote_up
        vc = @claim.vote_count.to_i
        Card::Env.params['vote'] = "force-down"
        @claim.vote_count_card.update_attributes! nil
        uv_card = Card::Auth.current.downvotes_card
        vote_item_names = uv_card.item_names
        expect(vote_item_names.include?"~#{@claim.id}").to be true
        expect(@claim.vote_count.to_i).to eq vc-2
      end
      it "votes force-neutral" do
        @claim.vote_count_card.vote_up
        vc = @claim.vote_count.to_i
        Card::Env.params['vote'] = "force-neutral"
        @claim.vote_count_card.update_attributes! nil
        expect(@claim.vote_count.to_i).to eq vc-1
      end
    end

  end
  describe "content view" do
    before do
      Card::Auth.as_bot  do
        @card.save!
      end
    end
    let(:content_view)  { @card.format.render_content }
    it "has 'vote up' button" do
      assert_view_select content_view, 'button i[class~=fa-angle-up]'
      assert_view_select content_view,
                         'button[disabled="disabled"] i[class~=fa-angle-up]',
                         :count=>0
    end
    it "has 'vote down' button" do
      assert_view_select content_view, 'button i[class~=fa-angle-down]'
      assert_view_select content_view,
                         'button[disabled="disabled"] i[class~=fa-angle-down]',
                         :count=>0
    end
    context "when voted up" do
      before do
        Card::Auth.as_bot do
          @card.vote_up
          @card.save
        end
      end
      it "has disabled 'vote up' button" do
        assert_view_select content_view,
                           'button[disabled="disabled"] i[class~=fa-angle-up]'
      end
    end
    context "when voted down" do
      before do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save
        end
      end
      it "has disabled 'vote down' button" do
        assert_view_select content_view,
                           'button[disabled="disabled"] i[class~=fa-angle-down]'
      end
    end
  end

  describe "session votes" do
    subject { @vcard.raw_content.to_i }
    before do
      Card::Auth.current_id = Card::AnonymousID
      @topic = get_a_sample_topic
      @vcard = @topic.vote_count_card
    end


    describe "#vote_up" do
      context "when voted down" do
        before do
          @vcard.vote_down
          @vc = @vcard.raw_content.to_i
          @vcard.vote_up
        end
        it "increases vote count" do
          is_expected.to eq @vc+1
        end
      end
      context "when not voted" do
        before do
          @vc = @vcard.raw_content.to_i
          @vcard.vote_up
        end
        it "increases vote count" do
          is_expected.to eq @vc+1
        end
        it "increases upvote count only once" do
          @vcard.vote_up
          is_expected.to eq @vc+1
        end
        it 'gets saved after signin' do
          Card::Auth.current_id = Card.fetch_id 'Joe Admin'
          @vcard.save_session_votes
          @vcard = @topic.vote_count_card
          expect(@vcard.content.to_i).to eq @vc+1
        end
      end
    end

    describe "#vote_down" do
      context "when voted up" do
        before do
          @vcard.vote_up
          @vc = @vcard.raw_content.to_i
          @vcard.vote_down
        end
        it "decreases vote count" do
          is_expected.to eq @vc-1
        end
      end
      context "when not voted" do
        before do
            @vc = @vcard.content.to_i
            @vcard.vote_down
        end
        it "decreases vote count" do
          is_expected.to eq @vc-1
        end
        it "decreases upvote count only once" do
          @vcard.vote_down
          is_expected.to eq @vc-1
        end
        it 'gets saved after signin' do
          Card::Auth.current_id = Card.fetch_id 'Joe Admin'
          @vcard.save_session_votes
          @vcard = @topic.vote_count_card
          expect(@vcard.content.to_i).to eq @vc-1
        end
      end
    end
  end
end
