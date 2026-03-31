require 'digest'
require 'fileutils'
require_relative '../lib/memory'

module Llm
  module Services
    class Cacher
      def initialize(thread, prompt)
        @thread = thread
        @prompt = prompt
      end

      def fetch
        begin
          response = yield
          add_to_memory(response)

        rescue => e
          print "Error in fetch: #{e.class} - #{e.message}\n"
          raise
        end
        response
      end

      private

      def add_to_memory(response)
        history = ::Llm::Memory.read(@thread)
        history << { role: 'user', content: @prompt }
        history << { role: 'assistant', content: response }
        save(history)
      end

      def save(data)
        ::Llm::Memory.persist(@thread, data)
      end
    end
  end
end
