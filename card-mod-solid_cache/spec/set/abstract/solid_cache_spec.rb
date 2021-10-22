# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::SolidCache do
  context "render core view of a card" do
    let(:core_view) { "Alpha Z[/Z]" }

    context "with solid cache" do
      it "saves core view in solid cache card" do
        format_subject :base, &:render_core
        Card::Auth.as_bot do
          expect(card_subject.solid_cache_card).to be_instance_of(Card)
          expect(card_subject.solid_cache_card.content).to eq(core_view)
        end
      end

      it "uses solid cache card content as core view", as_bot: true do
        format_subject :base do |format|
          card_subject.solid_cache_card.update! content: "cache"
          expect(format._render_core).to eq "cache"
        end
      end
    end

    context "with solid cache disabled" do
      it "ignores solid cache card content", as_bot: true do
        format_subject :base do |format|
          card_subject.solid_cache_card.update! content: "cache"
          expect(format._render_core(hide: :solid_cache)).to eq core_view
        end
      end
    end
  end

  # rubocop:disable ClassAndModuleChildren
  # rubocop:disable Documentation
  context "when cached content expired" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "volatile", codename: "volatile",
                     content: "chopping"
        Card.create! name: "cached", codename: "cached",
                     content: "chopping and {{volatile|core}}"
      end
    end
    describe ".cache_update_trigger" do
      before do
        module Card::Set::Self::Cached
          extend Card::Set
          include_set Card::Set::Abstract::SolidCache

          ensure_set { Card::Set::Self::Volatile }
          cache_update_trigger Card::Set::Self::Volatile do
            Card["cached"]
          end
        end
      end

      it "updates solid cache card" do
        Card::Auth.as_bot do
          Card["volatile"].update! content: "changing"
        end
        expect(Card["cached", :solid_cache].content)
          .to eq "chopping and changing"
      end
    end

    describe ".cache_expire_trigger" do
      before do
        module Card::Set::Self::Cached
          extend Card::Set
          include_set Card::Set::Abstract::SolidCache

          ensure_set { Card::Set::Self::Volatile }
          cache_expire_trigger Card::Set::Self::Volatile do
            Card["cached"]
          end
        end
      end

      it "expires solid cache card" do
        Card["cached"].format(:html)._render_core
        expect(Card["cached", :solid_cache]).to be_instance_of Card
        Card::Auth.as_bot do
          Card["volatile"].update! content: "changing"
        end
        expect(Card["cached", :solid_cache]).to be_falsey
      end
    end
  end
  # rubocop:enable ClassAndModuleChildren
  # rubocop:enable Documentation
end
