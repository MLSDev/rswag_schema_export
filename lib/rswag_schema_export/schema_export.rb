module RswagSchemaExport
  class Export
    def run
      abort("Set up RswagSchemaExport.config.schemas") unless RswagSchemaExport.config.schemas

      RswagSchemaExport.config.schemas.map do |schema|
        next if File.file?(schema)

        message = "Not found schema at #{schema}.
               For generate schema run: RAILS_ENV=test rake rswag:specs:swaggerize"
        abort(message)
      end

      begin
        client = ::RswagSchemaExport::Client.new
        RswagSchemaExport.config.schemas.map do |schema|
          schema_id = schema.gsub(/[^a-zA-Z0-9\-]/, "_")
          key = "schemas/#{client.app_name}/#{client.stage}_#{schema_id}/versions/#{Time.now.getutc.iso8601}.json"
          # Upload latest version to app
          client.upload_file(key, schema)

          puts("Schema has been successfully exported. Stage: #{client.stage} | Key: #{key}")
        end
        puts("Export finished")
      rescue StandardError => e
        abort(e.message)
      end
    end
  end
end
