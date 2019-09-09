require "azure/storage/blob"
require "aws-sdk-s3"

module RswagSchemaExport
  class Client
    attr_reader :stage, :app_name

    def initialize(stage)
      @app_name = ENV["APP_NAME"] || "app"
      @stage = stage || "develop"
    end

    def client # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity:
      if aws_client?
        abort("RSWAG_AWS_ACCESS_KEY_ID is not defined") unless ENV["RSWAG_AWS_ACCESS_KEY_ID"]
        abort("RSWAG_AWS_SECRET_ACCESS_KEY is not defined") unless ENV["RSWAG_AWS_SECRET_ACCESS_KEY"]
        abort("RSWAG_AWS_REGION is not defined") unless ENV["RSWAG_AWS_REGION"]
        abort("RSWAG_AWS_BUCKET is not defined") unless ENV["RSWAG_AWS_BUCKET"]

        @client ||= Aws::S3::Resource.new(access_key_id: ENV["RSWAG_AWS_ACCESS_KEY_ID"],
                                          secret_access_key: ENV["RSWAG_AWS_SECRET_ACCESS_KEY"],
                                          region: ENV["RSWAG_AWS_REGION"])
      else
        abort("RSWAG_AZURE_STORAGE_ACCOUNT_NAME is not defined") unless ENV["RSWAG_AZURE_STORAGE_ACCOUNT_NAME"]
        abort("RSWAG_AZURE_STORAGE_ACCESS_KEY is not defined") unless ENV["RSWAG_AZURE_STORAGE_ACCESS_KEY"]
        abort("RSWAG_AZURE_CONTAINER is not defined") unless ENV["RSWAG_AZURE_CONTAINER"]

        @client = Azure::Storage::Blob::BlobService.create(
          storage_account_name: ENV["RSWAG_AZURE_STORAGE_ACCOUNT_NAME"],
          storage_access_key: ENV["RSWAG_AZURE_STORAGE_ACCESS_KEY"]
        )
      end
    end

    def upload_file(key, file)
      if aws_client?
        client.bucket(ENV["RSWAG_AWS_BUCKET"]).object(key).upload_file(file)
      else
        client.create_block_blob(ENV["RSWAG_AZURE_CONTAINER"], key, ::File.open(file, &:read))
      end
    end

    def fetch_versions(schema_id)
      if aws_client?
        bucket.objects(prefix: "schemas/#{app_name}/#{stage}_#{schema_id}/versions").collect(&:key)
      else
        prefix = "schemas/#{app_name}/#{stage}_#{schema_id}/versions"
        client.list_blobs(ENV["RSWAG_AZURE_CONTAINER"], prefix: prefix).collect(&:name)
      end
    end

    def copy_latest_version_to_root(last_schema_key, schema_id)
      if aws_client?
        bucket.object(last_schema_key)
              .copy_to("#{ENV['RSWAG_BUCKET']}/schemas/#{app_name}/#{stage}_#{schema_id}/schema.json")
      else
        client.copy_blob(ENV["RSWAG_AZURE_CONTAINER"], "schemas/#{app_name}/#{stage}_#{schema_id}/schema.json",
                         ENV["RSWAG_AZURE_CONTAINER"], last_schema_key)
      end
    end

    def download_file(schema_id, path)
      if aws_client?
        bucket.object("schemas/#{app_name}/#{stage}_#{schema_id}/schema.json").download_file(path)
      else
        _blob, content = client.get_blob(ENV["RSWAG_AZURE_CONTAINER"],
                                         "schemas/#{app_name}/#{stage}_#{schema_id}/schema.json")
        ::File.open(path, "wb") { |f| f.write(content) }
      end
    end

    def clean(versions)
      old_versions = versions - versions.sort.last(5)
      if aws_client?
        old_versions.each { |key| bucket.object(key).delete }
      else
        old_versions.each { |key| client.delete_blob(ENV["RSWAG_AZURE_CONTAINER"], key) }
      end
    end

    private

    def bucket
      @bucket ||= client.bucket(ENV["RSWAG_AWS_BUCKET"]) if aws_client?
    end

    def aws_client?
      RswagSchemaExport.config.client&.to_sym == :aws
    end
  end
end
