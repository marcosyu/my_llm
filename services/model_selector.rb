module Llm
  module Services
    class ModelSelector
      RULES = [
        [/code|refactor|syntax|naming|method|variable/i, 'deepseek-coder'],
        [/plan|architecture|multi-step|integrate/i, 'llama3']
      ].freeze

      def self.for(prompt)
        new(prompt).call
      end

      def initialize(prompt)
        @prompt = prompt.to_s
      end

      def call
        RULES.each do |pattern, model|
          if @prompt.match?(pattern)
            print "Using model: #{model}\n"
            return model
          end
        end

        'mistral'
      end
    end
  end
end
