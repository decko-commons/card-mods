RSpec.describe Card::Set::Abstract::Import do
  let(:card) { "FirstTestImport".card }

  def with_import_rows hash, &block
    Card::Env.with_params import_rows: hash, &block
  end

  specify "set loading works" do
    expect(card).to be_a(described_class)
  end

  describe "#data_import?" do
    subject { card.data_import? }

    example "no data given" do
      is_expected.to be_falsey
    end

    example "an empty hash given" do
      with_import_rows({}) { is_expected.to be_falsey }
    end

    example "an import value" do
      with_import_rows(1 => true) { is_expected.to be_truthy }
    end
  end
end
