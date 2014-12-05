def self.check_mails
  Gmail.new(Wagn.config.gmail_user,Wagn.config.gmail_password) do |gmail|
    gmail.inbox.emails(:unread).each do |email|
      msg = email.message
      user = Auth.as_bot do
        from = msg.from.first
        Card.search(:type=>"user", :right_plus=>[ {:codename=>"account"},
                                                  :right_plus=>[{:codename=>"email"}, :content=>from]]).first
      end
      if user
        old_id = Card::Auth.current_id
        Auth.current_id = user.id
        Card.create :name => msg.subject, :content => msg.text_part.body.raw_source
        Card::Auth.current_id = old_id
        email.delete!
      end
    end
  end
end