require 'json'

module RswagSchemaExport
  class Differ
    def self.call(previews_schema, new_schema)
      previews_schema_json = JSON.parse(File.read(previews_schema))
      previews_schema_json["host"] = "localhost"

      File.write(previews_schema, JSON.pretty_generate(previews_schema_json))

      new_schema_json = JSON.parse(File.read(new_schema))
      new_schema_json["host"] = "localhost"

      File.write(new_schema, JSON.pretty_generate(new_schema_json))

      diff = ::Swagger::Diff::Diff.new(previews_schema, new_schema)
      changes = []
      report = ""

      diff.changes.map do |topic|
        report += "#{topic.first}: #{topic.last} \n"
        changes << topic.last unless topic.last.empty?
      end
      if changes.empty?
        nil
      else
        report
      end
    end
  end
end
