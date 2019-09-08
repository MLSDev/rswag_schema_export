require "aws-sdk-s3"

module RswagSchemaExport
  class Import
    def run(stage = "develop")
      abort("Set up RswagSchemaExport.config.schemas") unless RswagSchemaExport.config.schemas
      abort("RSWAG_ACCESS_KEY_ID is not defined") unless ENV["RSWAG_ACCESS_KEY_ID"]
      abort("RSWAG_SECRET_ACCESS_KEY is not defined") unless ENV["RSWAG_SECRET_ACCESS_KEY"]
      abort("RSWAG_REGION is not defined") unless ENV["RSWAG_REGION"]
      abort("RSWAG_BUCKET is not defined") unless ENV["RSWAG_BUCKET"]
      app_name = ENV["APP_NAME"] || "app"

      begin
        RswagSchemaExport.config.schemas.map do |schema|
          s3 = Aws::S3::Resource.new(access_key_id: ENV["RSWAG_ACCESS_KEY_ID"],
                                     secret_access_key: ENV["RSWAG_SECRET_ACCESS_KEY"],
                                     region: ENV["RSWAG_REGION"])

          bucket = s3.bucket(ENV["RSWAG_BUCKET"])
          schema_id = schema.gsub(/[^a-zA-Z0-9\-]/, "_")

          # Copy latest version to root
          versions = bucket.objects(prefix: "schemas/#{app_name}/#{stage}_#{schema_id}/versions").collect(&:key)

          last_schema_key = versions.max
          bucket.object(last_schema_key)
                .copy_to("#{ENV['RSWAG_BUCKET']}/schemas/#{app_name}/#{stage}_#{schema_id}/schema.json")
          # Download schema.json
          bucket.object("schemas/#{app_name}/#{stage}_#{schema_id}/schema.json").download_file(schema)
          # Clean versions folder
          old_versions = versions - versions.sort.last(5)
          old_versions.each { |key| bucket.object(key).delete }

          puts("Schema has been successfully imported. Stage: #{stage} | Key: #{last_schema_key}")
        end
        yield if block_given?
        puts("Import finished")
      rescue StandardError => e
        abort(e.message)
      end
    end
  end
end
