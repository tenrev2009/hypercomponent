\
# frozen_string_literal: true

module HyperComponents
  module Rules
    # Plain-hash rules in Phase 1:
    # { 'type' => 'constraint'|'automation'|'variant',
    #   'when' => 'expression returning bool' (optional),
    #   'then' => [ { 'action' => 'set'|'clamp'|'warn'|'error'|'enable_behavior'|'disable_behavior', ... } ] }
    module RuleModel
      def self.split_by_type(rules)
        rules ||= []
        {
          'constraint' => rules.select { |r| r['type'] == 'constraint' },
          'automation' => rules.select { |r| r['type'] == 'automation' },
          'variant' => rules.select { |r| r['type'] == 'variant' }
        }
      end
    end
  end
end
