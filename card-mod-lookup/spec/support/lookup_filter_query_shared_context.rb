RSpec.shared_context "lookup filter query" do |filter_class|
  let(:filter_class) { filter_class }
  let(:default_filters) { {} }
  let(:default_sort) { {} }

  # for override
  def altered_results
    yield
  end

  def search filter
    altered_results { run_query filter, default_sort }
  end

  def run_query filter, sort
    filter_class.new(default_filters.merge(filter), sort).run
  end
end