describe Card::Set::Right::VoteCount do
  before do
    Card::Auth.signin "Joe Admin"
    @topic = create_topic "another voting topic"
    @card = @topic.vote_count_card
    Card::Auth.signin "Joe User"
  end

  it "default vote count is 1" do
    expect(@topic.vote_count.to_i).to eq 1
  end

  describe "#vote_status" do
    subject { @card.vote_status }

    context "when not voted by user" do
      it { is_expected.to eq(:no_vote) }
    end

    context "when upvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_up }
      end
      it { is_expected.to eq(:upvoted) }
    end

    context "when downvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_down }
      end
      it { is_expected.to eq(:downvoted) }
    end

    context "when not signed in" do
      subject do
        Card::Auth.signin Card::AnonymousID
        @card.vote_status
      end
      it { is_expected.to eq(:no_vote) }
    end
  end

  describe "#vote_up" do
    context "when voted down" do
      before do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save!
          @uvc = @topic.upvote_count.to_i
          @dvc = @topic.downvote_count.to_i
          @vc = @topic.vote_count.to_i
          @card = @topic.vote_count_card
          @card.vote_up
          @card.save!
        end
      end

      it "decreases downvote count" do
        Card::Auth.as_bot do
          expect(@topic.downvote_count.to_i).to eq(@dvc - 1)
        end
      end

      it "doesn't change upvote count" do
        Card::Auth.as_bot do
          expect(@topic.upvote_count.to_i).to eq(@uvc)
        end
      end

      it "increases vote count" do
        expect(@topic.vote_count.to_i).to eq(@vc + 1)
      end
    end

    context "when drag and drop the vote to middle of the list" do
      before do
        @uv_card = Card::Auth.current.upvotes_card
        @initial_vote_count = @uv_card.item_names.count

        Card::Auth.signin "Joe User"
        Card::Auth.as_bot do
          @card.vote_up
          @card.save!

          @topic1 = create_topic "another voting topic1"
          @card1 = @topic1.vote_count_card
        end

        Card::Auth.signin "Joe Admin"
        Card::Auth.as_bot do
          @topic2 = create_topic "another voting topic2"
          @card2 = @topic2.vote_count_card
        end

        Card::Auth.signin "Joe User"
        Card::Auth.as_bot do
          @card2.vote_up @topic1.id
          @card2.save!
        end
      end

      it "shows the new voted topic to middle of the list" do
        vote_item_names = @uv_card.refresh(true).item_names
        expect(vote_item_names[@initial_vote_count + 0]).to eq("~#{@topic.id}")
        expect(vote_item_names[@initial_vote_count + 1]).to eq("~#{@topic2.id}")
        expect(vote_item_names[@initial_vote_count + 2]).to eq("~#{@topic1.id}")
      end
    end

    context "when not voted" do
      before do
        Card::Auth.as_bot do
          @uvc = @topic.upvote_count.to_i
          @vc = @topic.vote_count.to_i
          @card.vote_up
          @card.save!
        end
      end

      it "increases upvote count" do
        Card::Auth.as_bot do
          expect(@topic.upvote_count.to_i).to eq(@uvc + 1)
        end
      end

      it "increases vote count" do
        expect(@topic.vote_count.to_i).to eq(@vc + 1)
      end

      it "increases upvote count only once" do
        Card::Auth.as_bot do
          card = @topic.vote_count_card
          card.vote_up
          card.save!
        end
        expect(@topic.upvote_count.to_i).to eq(@uvc + 1)
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
        uvc = @topic.upvote_count.to_i
        vc = @topic.vote_count.to_i
        Card::Auth.as_bot do
          @card.force_neutral
          @card.save!
        end
        expect(@topic.upvote_count.to_i).to eq(uvc - 1)
        expect(@topic.vote_count.to_i).to eq(vc - 1)
      end
    end

    context "when voted down" do
      it "decrease downvote count" do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save!
        end
        uvc = @topic.downvote_count.to_i
        vc = @topic.vote_count.to_i
        Card::Auth.as_bot do
          @card.force_neutral
          @card.save!
        end
        expect(@topic.downvote_count.to_i).to eq(uvc - 1)
        expect(@topic.vote_count.to_i).to eq(vc + 1)
      end
    end
  end

  describe "#vote_down" do
    context "when voted up" do
      before do
        Card::Auth.as_bot do
          @card.vote_up
          @card.save!
          @uvc = @topic.upvote_count.to_i
          @dvc = @topic.downvote_count.to_i
          @vc = @topic.vote_count.to_i
          @card = @topic.vote_count_card
          @card.vote_down
          @card.save!
        end
      end

      it "decreases upvote count" do
        Card::Auth.as_bot do
          expect(@topic.upvote_count.to_i).to eq(@uvc - 1)
        end
      end

      it "doesn't change downvote count" do
        Card::Auth.as_bot do
          expect(@topic.downvote_count.to_i).to eq(@dvc)
        end
      end

      it "decreases vote count" do
        expect(@topic.vote_count.to_i).to eq(@vc - 1)
      end
    end

    context "when not voted" do
      before do
        Card::Auth.as_bot do
          @dvc = @topic.downvote_count.to_i
          @vc = @topic.vote_count.to_i
          @card.vote_down
          @card.save!
        end
      end

      it "increases downvote count" do
        Card::Auth.as_bot do
          expect(@topic.downvote_count.to_i).to eq(@dvc + 1)
        end
      end

      it "decreases vote count" do
        expect(@topic.vote_count.to_i).to eq(@vc - 1)
      end

      it "increases downvote count only once" do
        Card::Auth.as_bot do
          card = @topic.vote_count_card
          card.vote_down
          card.save!
        end
        expect(@topic.downvote_count.to_i).to eq(@dvc + 1)
      end
    end
  end

  describe "event vote" do
    before do
      @vc = @topic.vote_count.to_i
    end

    context "signed in or anonymous with session_vote enabled" do
      def trigger_vote direction
        Card::Env.params["vote"] = direction.to_s
        @topic.vote_count_card.update! nil
      end

      def vote_items direction
        Card::Auth.current.send("#{direction}votes_card").item_names
      end

      it "votes up" do
        trigger_vote :up
        expect(vote_items(:up).include?("~#{@topic.id}")).to be true
        expect(@topic.vote_count.to_i).to eq(@vc + 1)
      end

      it "votes down" do
        trigger_vote :down
        expect(vote_items(:down).include?("~#{@topic.id}")).to be true
        expect(@topic.vote_count.to_i).to eq(@vc - 1)
      end

      it "votes force-up" do
        trigger_vote :down
        vc = @topic.vote_count.to_i
        trigger_vote "force-up"
        expect(vote_items(:up).include?("~#{@topic.id}")).to be true
        expect(@topic.vote_count.to_i).to eq(vc + 2)
      end

      it "votes force-down" do
        trigger_vote :up
        vc = @topic.vote_count.to_i
        trigger_vote "force-down"
        expect(vote_items(:down).include?("~#{@topic.id}")).to be true
        expect(@topic.vote_count.to_i).to eq(vc - 2)
      end

      it "votes force-neutral" do
        @topic.vote_count_card.vote_up
        vc = @topic.vote_count.to_i
        Card::Env.params["vote"] = "force-neutral"
        @topic.vote_count_card.update! nil
        expect(@topic.vote_count.to_i).to eq(vc - 1)
      end
    end
  end

  describe "content view" do
    before do
      Card::Auth.as_bot do
        @card.save!
      end
    end

    let(:content_view) { @card.format.render_content }
    it "has 'vote up' button" do
      assert_view_select content_view, "button i[class~=fa-chevron-up]"
      assert_view_select content_view,
                         'button[disabled="disabled"] i[class~=fa-chevron-up]',
                         count: 0
    end

    it "has 'vote down' button" do
      assert_view_select content_view, "button i[class~=fa-chevron-down]"
      assert_view_select(
        content_view,
        'button[disabled="disabled"] i[class~=fa-chevron-down]',
        count: 0
      )
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
                           'button[disabled="disabled"] i[class~=fa-chevron-up]'
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
        assert_view_select(
          content_view,
          'button[disabled="disabled"] i[class~=fa-chevron-down]'
        )
      end
    end
  end

  describe "session votes" do
    subject { @vcard.content.to_i }
    before do
      @topic = sample_topic
      @vcard = @topic.vote_count_card
      Card::Auth.signin Card::AnonymousID
    end

    describe "#vote_up" do
      context "when voted down" do
        before do
          @vcard.vote_down
          @vc = @vcard.content.to_i
          @vcard.vote_up
        end
        it "increases vote count" do
          is_expected.to eq(@vc + 1)
        end
      end

      context "when not voted" do
        before do
          @vc = @vcard.content.to_i
          @vcard.vote_up
        end

        it "increases vote count" do
          is_expected.to eq(@vc + 1)
        end

        it "increases upvote count only once" do
          @vcard.vote_up
          is_expected.to eq(@vc + 1)
        end

        it "gets saved after signin" do
          Card::Auth.signin "Joe Admin"
          @vcard.save_session_votes
          @vcard = @topic.vote_count_card
          expect(@vcard.content.to_i).to eq(@vc + 1)
        end
      end
    end

    describe "#vote_down" do
      context "when voted up" do
        before do
          @vcard.vote_up
          @vc = @vcard.content.to_i
          @vcard.vote_down
        end

        it "decreases vote count" do
          is_expected.to eq(@vc - 1)
        end
      end

      context "when not voted" do
        before do
          @vc = @vcard.content.to_i
          @vcard.vote_down
        end

        it "decreases vote count" do
          is_expected.to eq(@vc - 1)
        end

        it "decreases upvote count only once" do
          @vcard.vote_down
          is_expected.to eq(@vc - 1)
        end

        it "gets saved after signin" do
          Card::Auth.signin "Joe Admin"
          @vcard.save_session_votes
          @vcard = @topic.vote_count_card
          expect(@vcard.content.to_i).to eq(@vc - 1)
        end
      end
    end
  end
end
