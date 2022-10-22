RSpec.describe Card::ImportItem::HelperMethods do
  let :dummy_class do
    Class.new { include Card::ImportItem::HelperMethods }.tap do |klass|
      klass.define_method(:separator) {  |_field| return false }
    end
  end

  describe "#prep_fields" do
    it "gets rid of missing methods" do
      expect(dummy_class.new.prep_fields(one: 1, none: nil)).to eq(one: 1)
    end
  end
end
