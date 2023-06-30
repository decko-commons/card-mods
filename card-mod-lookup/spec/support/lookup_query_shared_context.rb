RSpec.shared_context "lookup query" do |query_class|
  let(:query_class) { query_class }

  # for override
  let(:default_filters) { {} }
  let(:default_sort) { {} }

  # for override
  def altered_results
    yield
  end

  def search filter={}
    altered_results { run_query filter, default_sort }
  end

  def run_query filter, sort
    query_class.new(default_filters.merge(filter), sort).run
  end
end
