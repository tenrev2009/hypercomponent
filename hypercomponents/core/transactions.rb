\
# frozen_string_literal: true

module HyperComponents
  module Core
    module Transactions
      def self.wrap(model, name, transparent: false)
        model.start_operation(name, true, transparent, true)
        yield
        model.commit_operation
      rescue => e
        model.abort_operation rescue nil
        raise e
      end
    end
  end
end
