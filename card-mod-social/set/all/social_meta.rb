format :text do
  def text_description
    truncate render_text_without_nests.strip, length: 200, separator: " "
  end
end

format :html do
  basket[:head_views] << :social_meta_tags

  view :social_meta_tags, unknown: :blank do
    shared = %w[title description image]
    meta_tags_for(:og, :property, shared + %w[url site_name type]) +
      meta_tags_for(:twitter, :name, shared + %w[card site creator])
  end

  # OPEN GRAPH

  def og_url
    card_url card.name.url_key
  end

  def og_site_name
    Card[:title]&.content
  end

  def og_type
    "article"
  end

  def og_title
    card.name
  end

  def og_description
    social_description
  end

  def og_image
    social_image
  end

  # TWITTER CARDS

  def twitter_card
    "summary"
  end

  def twitter_description
    social_description
  end

  def twitter_image
    social_image
  end

  # SHARED

  # NOTE: not cache safe
  def social_description
    @social_description ||= social_description_card&.format(:text)&.text_description
  end

  # NOTE: not cache safe
  def social_image
    @social_image ||= social_image_card&.format(:text)&.render_source
  end

  def social_image_card
    try(:image_card) || card.fetch(:image) || Card[:logo]
  end

  def social_description_card
    card.fetch(:description) || card
  end

  private

  def meta_tags_for prefix, field, properties
    properties.map do |property|
      next unless (content = try "#{prefix}_#{property}")
      meta_tag field, "#{prefix}:#{property}", content
    end.compact
  end

  def meta_tag attribute, property, content
    %(<meta #{attribute}="#{property}" content="#{content}">)
  end
end
