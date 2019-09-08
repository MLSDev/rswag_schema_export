module RswagSchemaExport
  class Export
    def run
      abort("Set up RswagSchemaExport.config.schemas") unless RswagSchemaExport.config.schemas
      abort("RSWAG_ACCESS_KEY_ID is not defined") unless ENV["RSWAG_ACCESS_KEY_ID"]
      abort("RSWAG_SECRET_ACCESS_KEY is not defined") unless ENV["RSWAG_SECRET_ACCESS_KEY"]
      abort("RSWAG_REGION is not defined") unless ENV["RSWAG_REGION"]
      abort("RSWAG_BUCKET is not defined") unless ENV["RSWAG_BUCKET"]

      stage = ENV["STAGE"] || "develop"
      app_name = ENV["APP_NAME"] || "app"

      RswagSchemaExport.config.schemas.map do |schema|
        next if File.file?(schema)

        message = "Not found schema at #{schema}.
               For generate schema run: RAILS_ENV=test rake rswag:specs:swaggerize"
        abort(message)
      end

      begin
        RswagSchemaExport.config.schemas.map do |schema|
          s3 = Aws::S3::Resource.new(access_key_id: ENV["RSWAG_ACCESS_KEY_ID"],
                                     secret_access_key: ENV["RSWAG_SECRET_ACCESS_KEY"],
                                     region: ENV["RSWAG_REGION"])
          schema_id = schema.gsub(/[^a-zA-Z0-9\-]/, "_")
          key = "schemas/#{app_name}/#{stage}_#{schema_id}/versions/#{Time.now.getutc.iso8601}.json"
          # Upload latest version to app
          s3.bucket(ENV["RSWAG_BUCKET"]).object(key).upload_file(schema)

          puts("Schema has been successfully exported. Stage: #{stage} | Key: #{key}")
        end
        puts("Export finished")
      rescue StandardError => e
        abort(e.message)
      end
    end
  end
end
