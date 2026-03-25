module Llm
  module Services
    class LocalFetcher
      def self.generate(prompt)
        uri = URI("http://localhost:11434/api/generate")
        req = Net::HTTP::Post.new(uri)
        req["Content-Type"] = "application/json"
        req.body = {
          model: model_selector(prompt),
          prompt: prompt,
          stream: true
        }.to_json

        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req) do |res|
            res.read_body do |chunk|
              # Each chunk may contain partial JSON lines
              begin
                data = JSON.parse(chunk)
                if data["response"]
                  print data["response"] # print partially
                end
              rescue JSON::ParserError
                # Sometimes partial JSON, ignore until complete
              end
            end
          end
        end
      end

      private

      def self.model_selector(prompt)
        if prompt.match?(/code|refactor|syntax|naming|method|variable/i)
          "deepseek-coder"
        elsif prompt.match?(/plan|architecture|multi-step|integrate/i)
          "llama3"
        else
          "mistral"
        end
      end
    end
  end
end
