module Cardio
  class Mod
    # method(s) for easy flag adding in specs
    module FlagSpecHelper
      def flag_subject subject, fields={}
        fields.reverse_merge! subject: subject,
                              status: "open",
                              flag_type: "Other Problem",
                              discussion: "me like cookie. you?"
        Card.create! type: :flag, fields: fields
      end
    end
  end
end
