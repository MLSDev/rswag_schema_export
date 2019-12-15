module RswagSchemaExport
  class Differ
    def self.call(previews_schema, new_schema)
      diff = Swagger::Diff::Diff.new(previews_schema, new_schema)
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
