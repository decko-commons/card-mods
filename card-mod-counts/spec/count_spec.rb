RSpec.describe Card::Count do
  let :card do
    instance_double "count card",
                    left_id: 1, right_id: 5,
                    compound?: true, recount: 10, hard_cached_count: true
  end
  let(:create_count) { described_class.send :create, card }

  describe ".create" do
    it "has count 10" do
      expect(create_count.value).to eq 10
    end
  end

  describe ".value" do
    context "when existing entry" do
      it "returns 10" do
        create_count
        expect(described_class.value(card)).to eq 10
      end
    end

    context "when new entry" do
      it "returns 10" do
        expect(described_class.value(card)).to eq 10
      end
    end
  end

  describe ".refresh" do
    it "returns 15" do
      expect(described_class.value(card)).to eq 10
      allow(card).to receive(:recount).and_return 15
      described_class.refresh card
      expect(described_class.value(card)).to eq 15
    end
  end

  describe ".step" do
    context "when existing entry" do
      it "returns 11" do
        create_count
        expect(described_class.step(card)).to eq 11
      end
    end

    context "when new entry" do
      it "returns 10" do
        expect(described_class.step(card)).to eq 10
      end
    end
  end
end
