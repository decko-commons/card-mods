delegate :api_tracker_card, to: :account_card

format :html do
  delegate :api_tracker_card, to: :card

  view :current_and_tracker_status, unknown: true, template: :haml

  view :buttons do
    [
      render_generate_button(show: :analytics),
      render_generate_button
    ]
  end

  def core_top_view
    :current_and_tracker_status
  end

  def generate_button_situation
    voo.explicit_show?(:analytics) ? :primary : :secondary
  end

  def generate_button_text
    key = ["google_analytics_api_key_",
           ("re" if card.content.present?),
           "generate_with",
           ("out" unless voo.explicit_show? :analytics),
           "_tracker"].compact.join
    t :"#{key}"
  end

  def generate_button_hidden_tags
    anal = voo.explicit_show?(:analytics) ? "yes" : "no"
    {
      card: { trigger: :generate_api_key,
              subcards: { api_tracker_card.name => { type: :toggle,
                                                     content: anal } } }
    }
  end
end
