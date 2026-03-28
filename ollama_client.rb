require 'net/http'
require 'json'
require 'fileutils'
require_relative 'services/local_fetcher'
require_relative 'services/web_fetcher'
require_relative 'services/cacher'
require_relative 'lib/memory'

module Llm
  class OllamaClient
    def initialize(prompt, thread: "default")
      @prompt = prompt
      @thread = thread
    end

    def ask
      return ::Llm::Services::LocalFetcher.generate(@prompt) unless online?

      links = Llm::Services::WebFetcher.search(@prompt)
      @content = links.map { |link| Llm::Services::WebFetcher.fetch_content(link) }.join("\n\n")

      ::Llm::Services::Cacher.new(@thread, @prompt).fetch do
        ::Llm::Services::LocalFetcher.generate(summarize(structured_prompt, @content))
      end
    end

    private

    def online?
      system("ping -c 1 8.8.8.8 > /dev/null 2>&1")
    end

    def structured_prompt
      <<~PROMPT
        You are a helpful assistant.

        Use this latest info:
        #{@content}

        Conversation:
        #{read_from_memory}

        User: #{@prompt}
        Assistant:
      PROMPT
    end

    def read_from_memory
      ::Llm::Memory.read(@thread).map do |msg|
        "#{msg[:role].capitalize}: #{msg[:content]}"
      end.join("\n")
    end

    def summarize(prompt, content)
      "Summarize the latest information and instructions for:\n#{prompt}\n\n#{content}"
    end
  end
end
