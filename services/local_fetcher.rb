module Llm
  module Services
    class LocalFetcher
      def self.generate(prompt, model)
        uri = URI("http://localhost:11434/api/generate")
        req = Net::HTTP::Post.new(uri)
        req["Content-Type"] = "application/json"
        req.body = {
          model: model,
          prompt: prompt,
          stream: true
        }.to_json
        full_response = []
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req) do |res|
            res.read_body do |chunk|
              begin
                data = JSON.parse(chunk)
                print data["response"] if data["response"]
                full_response << data["response"] if data["response"]
              rescue JSON::ParserError
                # Sometimes partial JSON, ignore until complete
              end
            end
          end
        end
        full_response.join
      end
    end
  end
end
