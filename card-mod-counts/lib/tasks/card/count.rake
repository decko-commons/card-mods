namespace :card do
  namespace :count do
    desc "recount flagged cards and update as needed"
    task refresh_flagged: :environment do
      Card::Count.refresh_flagged
    end
  end
end
