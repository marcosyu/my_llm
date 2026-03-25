require 'net/http'
require 'json'
require_relative 'services/local_fetcher'
require_relative 'services/web_fetcher'

module Llm
  class OllamaClient
    def initialize(prompt)
      @prompt = prompt
    end

    def ask
      return ::Llm::Services::LocalFetcher.generate(@prompt) unless online?

      links = Llm::Services::WebFetcher.search(@prompt)
      content = links.map { |link| Llm::Services::WebFetcher.fetch_content(link) }.join("\n\n")
      ::Llm::Services::LocalFetcher.generate(summarize(@prompt, content))
    end

    private

    def online?
      system("ping -c 1 8.8.8.8 > /dev/null 2>&1")
    end

    def summarize(prompt, content)
      "Summarize the latest information and instructions for:\n#{prompt}\n\n#{content}"
    end
  end
end
