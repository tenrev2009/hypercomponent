\
# frozen_string_literal: true

require 'zlib'

module HyperComponents
  module Data
    module Integrity
      module CRC
        def self.crc32(str)
          Zlib.crc32(str.to_s)
        end
      end
    end
  end
end
