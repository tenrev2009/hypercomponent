\
# frozen_string_literal: true

module HyperComponents
  module Params
    module Metadata
      def self.sorted_params(params_hash)
        params_hash
          .map { |id, meta| [id, meta] }
          .sort_by { |id, meta| [meta['group'].to_s, meta['order'].to_i, id.to_s] }
      end
    end
  end
end
