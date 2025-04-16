RSpec.describe Card::Set::All::GoogleAnalytics do
  before { Cardio.config.google_analytics_key = "UA-34941429-6" }

  after { Cardio.config.google_analytics_key = nil }

  describe "google_analytics_snippet" do
    it "handles vars" do
      expect(format_subject.render_google_analytics_snippets)
        .to match(/#{Regexp.escape "ga('set', 'anonymizeIp', true)"}/)
    end
  end
end
