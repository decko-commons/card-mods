RSpec.describe "blog.rb" do
  before do
    require "vendor/card-mods/card_mod_blog/spec/set/type/blog_spec.rb"
  end

  context "when formatting as HTML" do
    it "returns the expected edit fields in HTML format" do
      instance = Object.new

      def instance.edit_fields
        %i[date image description]
      end

      expected_edit_fields = %i[date image description]
      expect(instance.edit_fields).to eq(expected_edit_fields)
    end

    it "has a 'core' view with the 'haml' template" do
      instance = Object.new

      def instance.views
        { core: { template: :haml } }
      end

      view = instance.views[:core]
      expect(view[:template]).to eq(:haml)
    end
  end
end
