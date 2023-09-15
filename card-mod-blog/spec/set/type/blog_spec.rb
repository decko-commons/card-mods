RSpec.describe Card::Set::Type::Blog do
  context "when getting and setting attributes" do
      def card_subject
        Card.create! type: "Blog", name: "My Blog", fields: { 
          description: "description", 
          date: "DD/MM/YY" 
        }
  end

      check_views_for_errors
    end
end
