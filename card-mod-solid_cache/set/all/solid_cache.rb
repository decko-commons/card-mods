# for override
def solid_cache?
  false
end

module ClassMethods
  def clear_solid_cache
    Auth.as_bot do
      Card.search(right: { codename: "solid_cache" }).each do |card|
        card.update_columns trash: true
        card.expire
      end
    end
  end
end
