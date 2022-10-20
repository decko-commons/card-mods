RSpec.describe Card::Set::Right::ImportMap do
  def card_subject
    @card_subject ||= Card["first test import"].import_map_card
  end

  check_views_for_errors

  describe "HtmlFormat" do
    describe "#map_table" do
      it "escapes square brackets" do
        expect(format_subject.map_table(:basic))
          .to have_tag("input._import-mapping", with: {
                         name: "mapping[basic][castle]",
                         form: "mappingForm"
                       })
      end
    end

    describe "#suggest_link" do
      it "produces links for supported types" do
        expect(format_subject.suggest_link(:basic, "castle"))
          .to match(Regexp.new(Regexp.escape("/RichText")))
      end

      it "supports custom filter keys" do
        expect(format_subject.suggest_link(:basic, "woot"))
          .to match(Regexp.new(Regexp.escape(CGI.escape("filter[basically]"))))
      end
    end
  end

  describe "#map" do
    it "contains a key for each mapped column" do
      expect(card_subject.map.keys).to eq(Card::TestImportItem.mapped_column_keys)
    end

    it "maps existing names to ids" do
      expect(card_subject.map[:basic]["A"]).to eq("A".card_id)
    end

    it "maps non-existing names to nil" do
      expect(card_subject.map[:basic])
        .to include("castle" => nil)
    end

    it "handles blank content" do
      card_subject.content = ""
      expect(card_subject.map).to be_a(Hash)
    end
  end

  describe "#auto_map!" do
    it "creates a map based on auto matching" do
      initial_content = card_subject.content
      expect(card_subject.auto_map!).to eq(initial_content)
    end
  end

  describe "event: update_import_mapping" do
    it "updates map based on 'mapping' parameter" do
      card = update_with_mapping_param basic: { "castle" => "B" }
      expect(card.map[:basic]["castle"]).to eq("B".card_id)
    end

    it "catches error if mapping is not a card" do
      card = update_with_mapping_param basic: { "castle" => "Not a card" }
      expect(card.errors[:content]).to include(/invalid RichText mapping/)
    end

    it "catches error if mapping has the wrong type" do
      card = update_with_mapping_param basic: { "castle" => "Joe User" }
      expect(card.errors[:content]).to include(/invalid RichText mapping/)
    end

    it "catches error if data types are wonky" do
      card = update_with_mapping_param basic: { "castle" => { wtf: "really!?" } }
      expect(card.errors[:content]).to include(/invalid RichText mapping/)
    end

    it "catches non unique keys in auto add" do
      card = update_with_mapping_param basic: { "A" => "AutoAdd" }
      expect(card.refresh(true).map[:basic]["A"]).to eq("AutoAddFailure")
    end

    it "auto adds", as_bot: true do
      update_with_mapping_param basic: { "castle" => "AutoAdd" } do |card|
        expect(status_for_item(card, 0)).to eq(:ready)
      end
    end
  end

  describe "event: update_import_status" do
    it "moves newly valid items to 'ready'" do
      update_with_mapping_param basic: { "castle" => "B" } do |card|
        expect(status_for_item(card, 1)).to eq(:ready)
      end
    end

    it "keeps badly mapped items in 'not ready'" do
      update_with_mapping_param(basic: { "castle" => "not a card" }) do |card|
        expect(status_for_item(card, 4)).to eq(:ready)
      end
    end
  end

  describe "HtmlFormat#tab_title" do
    it "gives counts for total and unmapped values" do
      expect(format_subject.tab_title(:basic))
        .to have_tag("div.tab-title") do
          with_tag "span.tab-badge" do
            with_tag "span.badge-label" do
              "(1) RichTexts"
            end
            with_tag("span.badge-count") { 2 }
          end
        end
    end
  end

  describe "CsvFormat view: export" do
    it "exports mappings for a given type" do
      Card::Env.params[:map_type] = "basic"
      csv = <<-CSV.strip_heredoc
        Name in File,Name in My Deck,My Deck ID
        castle,,
        A,A,#{'A'.card_id}
      CSV
      expect(card_subject.format(:csv).render_export).to eq(csv)
    end
  end

  describe "#mapping_from_param" do
    it "unescapes escaped keys" do
      with_mapping_param basic: { "A+B" => "C" } do
        expect((card_subject.send :mapping_from_param)[:basic]["A B"]).to eq("C")
      end
    end
  end
end

def status_for_item map_card, index
  map_card.left.import_status_card.status.item_hash(index)[:status]
end

def with_mapping_param value
  Card::Env.with_params(mapping: value) { yield }
end

def update_with_mapping_param value
  with_mapping_param(value) do
    card_subject.update({})
  end
  card_subject
end
