require "aws-sdk-s3"

module RswagSchemaExport
  class Import
    def run
      abort("RSWAG_SCHEMA_PATH is not defined. Example: tmp/swagger/swagger.json") unless ENV["RSWAG_SCHEMA_PATH"]
      abort("RSWAG_ACCESS_KEY_ID is not defined") unless ENV["RSWAG_ACCESS_KEY_ID"]
      abort("RSWAG_SECRET_ACCESS_KEY is not defined") unless ENV["RSWAG_SECRET_ACCESS_KEY"]
      abort("RSWAG_REGION is not defined") unless ENV["RSWAG_REGION"]
      abort("RSWAG_BUCKET is not defined") unless ENV["RSWAG_BUCKET"]

      stage = ENV["STAGE"] || "develop"
      app_name = ENV["APP_NAME"] || "app"

      begin
        s3 = Aws::S3::Resource.new(access_key_id: ENV["RSWAG_ACCESS_KEY_ID"],
                                   secret_access_key: ENV["RSWAG_SECRET_ACCESS_KEY"],
                                   region: ENV["RSWAG_REGION"])

        bucket = s3.bucket(ENV["RSWAG_BUCKET"])
        # Copy latest version to root
        versions = bucket.objects(prefix: "schemas/#{app_name}/#{stage}_schemas/versions").collect(&:key)

        last_schema_key = versions.max
        bucket.object(last_schema_key).copy_to("#{ENV['RSWAG_BUCKET']}/schemas/#{app_name}/#{stage}_schemas/schema.json")
        # Download schema.json
        if block_given?
          bucket.object("schemas/#{app_name}/#{stage}_schemas/schema.json").download_file("schema.json")
          yield
        else
          bucket.object("schemas/#{app_name}/#{stage}_schemas/schema.json").download_file(ENV["RSWAG_SCHEMA_PATH"])
        end
        # Clean versions folder
        old_versions = versions - versions.sort.last(5)
        old_versions.each { |key| bucket.object(key).delete }

        puts("Schema has been successfully imported. Stage: #{stage} | Key: #{last_schema_key}")
      rescue StandardError => e
        abort(e.message)
      end
    end
  end
end
