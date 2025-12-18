\
# frozen_string_literal: true

module HyperComponents
  module Data
    module Integrity
      module Backups
        MAX = 3

        def self.push(record, payload_b64, payload_crc)
          record['last_good_payloads'] ||= []
          record['last_good_payloads'].unshift({ 'payload' => payload_b64, 'crc' => payload_crc, 'ts' => Time.now.to_i })
          record['last_good_payloads'] = record['last_good_payloads'].take(MAX)
        end

        def self.latest(record)
          (record['last_good_payloads'] || []).first
        end
      end
    end
  end
end
