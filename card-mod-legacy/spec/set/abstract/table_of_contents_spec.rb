# -*- encoding : utf-8 -*-

# FIXME: - this seems like a LOT of testing but it doesn't cover a ton of ground
# I think we should move the rendering tests into basic and trim this to about
# a quarter of its current length

RSpec.describe Card::Set::Abstract::TableOfContents do
  RSpec::Matchers.define :have_toc do
    match do |card|
      values_match?(/Table of Contents/, card.format.render_open_content)
    end
  end

  let(:c1) { "Onne Heading".card }
  let(:c2) { "Twwo Heading".card }
  let(:c3) { "Three Heading".card }
  let(:rule_card) { c1.rule_card(:table_of_contents) }

  context "when there is a general toc rule of 2" do
    before do
      Card::Auth.as_bot do
        create %i[basic type table_of_contents], "2"
      end
    end

    specify do
      expect(c1.type_id).to eq(Card::BasicID)
      expect(rule_card).to be_a Card
    end

    describe ".rule" do
      it "has a value of 2" do
        expect(rule_card.content).to eq("2")
        expect(c1.rule(:table_of_contents)).to eq("2")
      end
    end

    describe "renders with/without toc" do
      it "does not render for 'Onne Heading'" do
        expect(c1).not_to have_toc
      end

      it "renders for 'Twwo Heading'" do
        expect(c2).to have_toc
      end

      it "renders for 'Three Heading'" do
        expect(c3).to have_toc
      end
    end
  end

  context "when I change the general toc setting to 1" do
    before do
      rule_card.content = "1"
    end

    describe ".rule" do
      it "has a value of 1" do
        expect(c1.rule(:table_of_contents)).to eq("1")
      end
    end

    describe "renders with/without toc" do
      it "does not render toc for 'Onne Heading'" do
        expect(c1).to have_toc
      end

      it "renders toc for 'Twwo Heading'" do
        expect(c2).to have_toc
      end

      it "does not render for 'Twwo Heading' when changed to 3" do
        rule_card.content = "3"
        expect(c2.rule(:table_of_contents)).to eq("3")
        expect(c2).not_to have_toc
      end
    end
  end

  context "when I use CardtypeE cards" do
    before do
      Card::Auth.as_bot do
        @c1 = Card.create name: "toc1", type: "CardtypeE",
                          content: Card["Onne Heading"].content
        @c2 = Card.create name: "toc2", type: "CardtypeE",
                          content: Card["Twwo Heading"].content
        @c3 = Card.create name: "toc3", type: "CardtypeE",
                          content: Card["Three Heading"].content
      end
      expect(@c1.type_name).to eq("Cardtype E")
      @rule_card = @c1.rule_card(:table_of_contents)

      expect(@c1).to be
      expect(@c2).to be
      expect(@c3).to be
      expect(@rule_card).to be
    end

    describe ".rule" do
      it "has a value of 0" do
        expect(@c1.rule(:table_of_contents)).to eq("0")
        expect(@rule_card.content).to eq("0")
      end
    end

    describe "renders without toc" do
      it "does not render for 'Onne Heading'" do
        expect(@c1).not_to have_toc
      end

      it "renders for 'Twwo Heading'" do
        expect(@c2).not_to have_toc
      end

      it "renders for 'Three Heading'" do
        expect(@c3).not_to have_toc
      end
    end

    describe ".rule_card" do
      it "doesn't have a type rule" do
        expect(@rule_card).to be
        expect(@rule_card.name).to eq("*all+*table of contents")
      end

      it "get the same card without the * and singular" do
        expect(@c1.rule_card(:table_of_contents)).to eq(@rule_card)
      end
    end
  end

  context "when I create a new rule" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "RichText+*type+*table of contents", content: "2"
        @c1 = Card.create! name: "toc1", type: "CardtypeE",
                           content: Card["Onne Heading"].content
        @c2 = Card.create! name: "toc2",
                           content: Card["Twwo Heading"].content
        @c3 = Card.create! name: "toc3",
                           content: Card["Three Heading"].content
        expect(@c1.type_name).to eq("Cardtype E")
        @rule_card = @c1.rule_card(:table_of_contents)

        expect(@c1).to be
        expect(@c2).to be
        expect(@c3).to be
        expect(@rule_card.name).to eq("*all+*table of contents")
        if (c = Card["CardtypeE+*type+*table of content"])
          c.content = "2"
          c.save!
        else
          Card.create! name: "CardtypeE+*type+*table of content", content: "2"
        end
      end
    end

    it "takes on new setting value" do
      c = Card["toc1"]
      expect(c.rule_card(:table_of_contents).name)
        .to eq("CardtypeE+*type+*table of content")
      expect(c.rule(:table_of_contents)).to eq("2")
    end

    describe "renders with/without toc" do
      it "does not render for 'Onne Heading'" do
        expect(@c1).not_to have_toc
      end

      it "renders for 'Twwo Heading'" do
        expect(@c2.rule(:table_of_contents)).to eq("2")
        expect(@c2).to have_toc
      end

      it "renders for 'Three Heading'" do
        expect(@c3).to have_toc
      end
    end
  end

  context "when I change the general toc setting to 1" do
    let(:c1) { Card["Onne Heading"] }
    let(:c2) { Card["Twwo Heading"] }
    let(:rule_card) { c1.rule_card(:table_of_contents) }

    before do
      rule_card.content = "1"
    end

    describe ".rule" do
      it "has a value of 1" do
        expect(rule_card.content).to eq("1")
        expect(c1.rule(:table_of_contents)).to eq("1")
      end
    end

    describe "renders with/without toc" do
      it "does not render toc for 'Onne Heading'" do
        expect(c1).to have_toc
      end

      it "renders toc for 'Twwo Heading'" do
        expect(c2).to have_toc
      end

      it "does not render for 'Twwo Heading' when changed to 3" do
        rule_card.content = "3"
        expect(c2).not_to have_toc
      end
    end
  end
end
