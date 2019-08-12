require "aws-sdk-s3"

module RswagSchemaExport
  class Import
    def run(stage = "develop")
      abort("Set up RswagSchemaExport.config.shemas") unless RswagSchemaExport.config.shemas
      abort("RSWAG_ACCESS_KEY_ID is not defined") unless ENV["RSWAG_ACCESS_KEY_ID"]
      abort("RSWAG_SECRET_ACCESS_KEY is not defined") unless ENV["RSWAG_SECRET_ACCESS_KEY"]
      abort("RSWAG_REGION is not defined") unless ENV["RSWAG_REGION"]
      abort("RSWAG_BUCKET is not defined") unless ENV["RSWAG_BUCKET"]
      app_name = ENV["APP_NAME"] || "app"

      begin
        RswagSchemaExport.config.shemas.map do |schema|
          s3 = Aws::S3::Resource.new(access_key_id: ENV["RSWAG_ACCESS_KEY_ID"],
                                     secret_access_key: ENV["RSWAG_SECRET_ACCESS_KEY"],
                                     region: ENV["RSWAG_REGION"])

          bucket = s3.bucket(ENV["RSWAG_BUCKET"])
          schema_id= schema.gsub(/[^a-zA-Z0-9\-]/,"")

          # Copy latest version to root
          versions = bucket.objects(prefix: "schemas/#{app_name}/#{stage}_#{schema_id}_schemas/versions").collect(&:key)

          last_schema_key = versions.max
          bucket.object(last_schema_key)
              .copy_to("#{ENV['RSWAG_BUCKET']}/schemas/#{app_name}/#{stage}_#{schema_id}_schemas/schema.json")
          # Download schema.json
          bucket.object("schemas/#{app_name}/#{stage}_#{schema_id}_schemas/schema.json").download_file(schema)
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
