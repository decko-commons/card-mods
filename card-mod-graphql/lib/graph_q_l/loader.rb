module GraphQL
  module Loader
    def self.load_mod_queries
      Cardio.config.paths["lib/graph_q_l/types/query.rb"].existent.each { |q| load q }
    end
  end
end
