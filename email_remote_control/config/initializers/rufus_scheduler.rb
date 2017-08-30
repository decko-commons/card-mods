if Decko.config.respond_to?(:gmail_user) && Decko.config.gmail_user
  require 'rufus-scheduler'

  scheduler = Rufus::Scheduler.new

  scheduler.every Decko.config.gmail_interval do
    Card::Set::Self::GmailRemote.check_mails
  end
end
