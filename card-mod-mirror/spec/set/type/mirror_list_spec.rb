# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MirrorList do
  let(:listed_by) { Card.fetch("Darles Chickens+books").item_names.sort }

  before do
    Card::Auth.as_bot do
      #create_mirrored_list "Parry Hotter+authors", "[[Darles Chickens]]"
      Card.create! name: "Parry Hotter+authors",
                   content: "Darles Chickens",
                   type: :mirrored_list
      Card.create! name: "50 grades of shy+authors",
                   content: "Darles Chickens\nStam Broker",
                   type: :mirrored_list
    end
  end
  it "doesn't allow non-cardtype as right part" do
    expect do
      Card["Parry Hotter+authors"].update!(name: "Parry Hotter+hidden")
    end.to raise_error(ActiveRecord::RecordInvalid,
                       /Name must have a cardtype name as right part/)
  end

  context "when Darles Chickens is in the author list of" \
          '"Parry Hotter" and "50 grades of shy"' do
    describe "Darles Chickens+books" do
      subject { listed_by }

      it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }

      it "is recorded in the reference table" do
        search_result = Card.search(
          right_plus: ["books", link_to: "50 grades of shy"],
          return: :name
        )
        expect(search_result.sort).to eq ["Darles Chickens", "Stam Broker"]
      end

      context "when Darles Chickens is removed from Parry Hotter's list" do
        before do
          Card["Parry Hotter+authors"].update!(
            content: "Stam Broker"
          )
        end
        it { is_expected.to eq ["50 grades of shy"] }
      end
      context "when Parry Hotter is deleted" do
        before do
          Card["Parry Hotter"].delete
        end
        it { is_expected.to eq ["50 grades of shy"] }
      end
      context "when a new book is created that lists Darles Chickens" do
        before do
          Card::Auth.as_bot do
            Card.create!(
              name: "Adventures of Buckleharry Finn",
              type: "book",
              subcards: {
                "+authors" => { content: "[[Darles Chickens]]", type: "mirrored list" }
              }
            )
          end
        end
        it do
          is_expected.to eq(
            ["50 grades of shy", "Adventures of Buckleharry Finn",
             "Parry Hotter"]
          )
        end
      end
      context "when Darles Chickens is added to a book's list" do
        before do
          Card::Auth.as_bot do
            Card.create!(
              name: "Adventures of Buckleharry Finn",
              type: "book",
              subcards: {
                "+authors" => { content: "[[Stam Broker]]", type: :mirrored_list }
              }
            )
            Card.fetch("Adventures of Buckleharry Finn+authors")
                .update!(content: "[[Darles Chickens]]")
          end
        end
        it do
          is_expected.to eq(
            [
              "50 grades of shy",
              "Adventures of Buckleharry Finn",
              "Parry Hotter"
            ]
          )
        end
      end

      it "raises an error when the cardtype of Parry Hotter changed" do
        expect do
          Card["Parry Hotter"].update! type: :basic
        end.to raise_error(ActiveRecord::RecordInvalid,
                           /cannot change type of item in mirrors/)
      end

      context "when the name of Parry Hotter changed to Parry Moppins" do
        before do
          Card::Auth.as_bot do
            Card["Parry Hotter"].update! name: "Parry Moppins"
          end
        end
        it { is_expected.to eq ["50 grades of shy", "Parry Moppins"] }
      end

      context "when the name of Darles Chickens changed" do
        before { Card["Darles Chickens"].update! name: "Darles Eggs" }

        subject { Card.fetch("Darles Eggs+books").item_names.sort }

        it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }
      end

      context "when the cardtype of Darles Chickens changed" do
        it "raises error" do
          expect do
            Card["Darles Chickens"].update! type: :basic
          end.to raise_error(ActiveRecord::RecordInvalid,
                             /cannot change type of item in mirrors/)
        end
      end

      context "when the name of Darles Chickens+books changed" do
        it "raises error" do
          expect do
            Card["Darles Chickens+books"].update! name: "Darles Chickens+authors"
          end.to raise_error(ActiveRecord::RecordInvalid, /wrong cardtype/)
        end
      end

      context "when the name of the cardtype books changed" do
        before do
          Card::Auth.as_bot { Card["book"].update! name: "literature" }
        end
        subject { Card.fetch("Darles Chickens+literature").item_names.sort }

        it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }
      end
    end
  end
end
