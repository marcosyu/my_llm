require 'open-uri'
require 'nokogiri'

module Llm
  module Services
    class WebFetcher
      def self.search(query, max_results: 3)
        encoded_query = URI.encode_www_form_component(query)
        url = "https://duckduckgo.com/html/?q=#{encoded_query}"
        html = URI.open(url).read
        doc = Nokogiri::HTML(html)

        links = doc.css('a.result__a').map { |a| a['href'] }
        links.take(max_results)
      end

      def self.fetch_content(url)
        URI.open(url).read[0..4000]
      rescue
        "Failed to fetch content from #{url}"
      end
    end
  end
end
