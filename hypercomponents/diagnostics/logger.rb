# frozen_string_literal: true

module HyperComponents
  module Diagnostics
    module Logger
      LEVELS = {
        debug: 0,
        info:  1,
        warn:  2,
        error: 3,
        off:   99
      }.freeze

      @level = :info

      class << self
        def level
          @level
        end

        def level=(value)
          sym = begin
            value.to_sym
          rescue
            :info
          end
          @level = LEVELS.key?(sym) ? sym : :info
        end

        def log(lvl, msg)
          return if @level == :off
          return unless LEVELS[lvl] && LEVELS[lvl] >= LEVELS[@level]
          puts "[HyperComponents][#{lvl.to_s.upcase}] #{msg}"
        end

        def debug(msg); log(:debug, msg); end
        def info(msg);  log(:info,  msg); end
        def warn(msg);  log(:warn,  msg); end
        def error(msg); log(:error, msg); end

        def exception(e, context = nil)
          where = context ? " #{context}" : ""
          error("#{where} #{e.class}: #{e.message}")
          bt = e.backtrace && e.backtrace.first(12)
          puts(bt.join("\n")) if bt
        end
      end
    end
  end
end

