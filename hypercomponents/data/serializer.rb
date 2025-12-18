\
# frozen_string_literal: true

require 'json'
require 'zlib'
require 'base64'

module HyperComponents
  module Data
    module Serializer
      def self.encode(obj)
        json = JSON.generate(obj)
        compressed = Zlib::Deflate.deflate(json, Zlib::BEST_SPEED)
        Base64.strict_encode64(compressed)
      end

      def self.decode(b64)
        return nil if b64.nil? || b64.to_s.empty?
        compressed = Base64.strict_decode64(b64)
        json = Zlib::Inflate.inflate(compressed)
        JSON.parse(json)
      rescue JSON::ParserError, Zlib::DataError, ArgumentError
        nil
      end
    end
  end
end
