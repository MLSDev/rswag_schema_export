require 'swagger/diff'

module RswagSchemaExport
  class Differ
    def self.call(previews_schema, new_schema)
      diff = Swagger::Diff::Diff.new(previews_schema, new_schema)
      report = ""

      diff.changes.map do |topic|
        report += "#{topic.first}: #{topic.last} \n"
      end
      report
    end
  end
end
