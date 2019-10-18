module RswagSchemaExport
  class Import
    def run
      abort("Set up RswagSchemaExport.config.schemas") unless RswagSchemaExport.config.schemas

      begin
        client = ::RswagSchemaExport::Client.new(ENV["STAGE"])
        RswagSchemaExport.config.schemas.map do |schema|
          schema_id = schema.gsub(/[^a-zA-Z0-9\-]/, "_")

          # Copy latest version to root
          versions = client.fetch_versions(schema_id)
          last_schema_key = versions.max

          client.copy_latest_version_to_root(last_schema_key, schema_id)
          # Download schema.json
          client.download_file(schema_id, schema)
          # Clean versions folder
          client.clean(versions)

          puts("Schema has been successfully imported. Stage: #{client.stage} | Key: #{last_schema_key}")
        end
        yield if block_given?
        puts("Import finished")
      rescue StandardError => e
        abort(e.message)
      end
    end
  end
end
