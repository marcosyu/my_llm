module Llm
  class Memory
    def self.read(thread)
      file = File.expand_path("~/.llm_threads/#{thread}.json")
      return [] unless File.exist?(file)

      JSON.parse(File.read(file), symbolize_names: true).first(18)
    end

    def self.persist(thread, data)
      file = File.expand_path("~/.llm_threads/#{thread}.json")
      FileUtils.mkdir_p(File.dirname(file)) unless File.exist?(file)

      File.open(file, 'w+') do |f|
        f.write(data.to_json)
      end
      data
    end
  end
end
