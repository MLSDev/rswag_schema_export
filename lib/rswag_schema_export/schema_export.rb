module RswagSchemaExport
  class Export
    def run
      abort("RSWAG_SCHEMA_PATH is not defined. Example: tmp/swagger/swagger.json") unless ENV["RSWAG_SCHEMA_PATH"]
      abort("RSWAG_ACCESS_KEY_ID is not defined") unless ENV["RSWAG_ACCESS_KEY_ID"]
      abort("RSWAG_SECRET_ACCESS_KEY is not defined") unless ENV["RSWAG_SECRET_ACCESS_KEY"]
      abort("RSWAG_REGION is not defined") unless ENV["RSWAG_REGION"]
      abort("RSWAG_BUCKET is not defined") unless ENV["RSWAG_BUCKET"]

      stage = ENV["STAGE"] || "develop"
      app_name = ENV["APP_NAME"] || "app"

      unless File.file?(ENV["RSWAG_SCHEMA_PATH"])
        message = "Not found schema at #{ENV['RSWAG_SCHEMA_PATH']}.
                 For generate schema run: RAILS_ENV=test rake rswag:specs:swaggerize"
        abort(message)
      end

      begin
        s3 = Aws::S3::Resource.new(access_key_id: ENV["RSWAG_ACCESS_KEY_ID"],
                                   secret_access_key: ENV["RSWAG_SECRET_ACCESS_KEY"],
                                   region: ENV["RSWAG_REGION"])

        key = "schemas/#{app_name}/#{stage}_schemas/versions/#{Time.now.getutc.iso8601}.json"
        # Download latest version to app
        s3.bucket(ENV["RSWAG_BUCKET"]).object(key).upload_file(ENV["RSWAG_SCHEMA_PATH"])

        puts("Schema has been successfully exported. Stage: #{stage} | Key: #{key}")
      rescue StandardError => e
        abort(e.message)
      end
    end
  end
end
