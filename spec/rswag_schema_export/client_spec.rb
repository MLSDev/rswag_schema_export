describe RswagSchemaExport::Client do
  subject { described_class.new(nil) }
  describe "#initialize" do
    it "default values" do
      expect(subject.stage).to eq("develop")
      expect(subject.app_name).to eq("app")
    end
  end

  describe "aws" do
    before do
      ENV["RSWAG_AWS_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_SECRET_ACCESS_KEY"] = "XXX"
      ENV["RSWAG_AWS_REGION"] = "us-east-1"
      ENV["RSWAG_AWS_BUCKET"] = "bucket-name"
    end

    describe "#client" do
      it "creates Aws::S3::Resource object" do
        expect(Aws::S3::Resource).to receive(:new)
        subject.client
      end
    end

    describe "#upload_file" do
      it do
        expect(Aws::S3::Resource).to receive(:new) do
          double.tap do |client|
            expect(client).to receive(:bucket).with("bucket-name") do
              double.tap do |bucket|
                expect(bucket).to receive(:object).with("key") do
                  double.tap do |object|
                    expect(object).to receive(:upload_file).with("file")
                  end
                end
              end
            end
          end
        end
        subject.upload_file("key", "file")
      end
    end

    describe "#fetch_versions" do
      it do
        expect(Aws::S3::Resource).to receive(:new) do
          double.tap do |client|
            expect(client).to receive(:bucket).with("bucket-name") do
              double.tap do |bucket|
                expect(bucket).to receive(:objects).with(prefix: "schemas/app/develop_423/versions") do
                  double.tap do |objects|
                    expect(objects).to receive(:collect)
                  end
                end
              end
            end
          end
        end
        subject.fetch_versions("423")
      end
    end

    describe "#copy_latest_version_to_root" do
      it do
        expect(Aws::S3::Resource).to receive(:new) do
          double.tap do |client|
            expect(client).to receive(:bucket).with("bucket-name") do
              double.tap do |bucket|
                expect(bucket).to receive(:object).with("key") do
                  double.tap do |object|
                    expect(object).to receive(:copy_to).with("/schemas/app/develop_4334/schema.json")
                  end
                end
              end
            end
          end
        end
        subject.copy_latest_version_to_root("key", "4334")
      end
    end

    describe "#download_file" do
      it do
        expect(Aws::S3::Resource).to receive(:new) do
          double.tap do |client|
            expect(client).to receive(:bucket).with("bucket-name") do
              double.tap do |bucket|
                expect(bucket).to receive(:object).with("schemas/app/develop_4334/schema.json") do
                  double.tap do |object|
                    expect(object).to receive(:download_file).with("tmp/schema.json")
                  end
                end
              end
            end
          end
        end
        subject.download_file("4334", "tmp/schema.json")
      end
    end

    describe "#clean" do
      it do
        expect(Aws::S3::Resource).to receive(:new) do
          double.tap do |client|
            expect(client).to receive(:bucket).with("bucket-name") do
              double.tap do |bucket|
                expect(bucket).to receive(:object).with(1) do
                  double.tap do |object|
                    expect(object).to receive(:delete)
                  end
                end
              end
            end
          end
        end
        subject.clean([1, 2, 3, 4, 5, 6])
      end
    end
  end

  describe "azure" do
    before do
      allow(RswagSchemaExport.config).to receive(:client).and_return(:azure)
      ENV["RSWAG_AZURE_STORAGE_ACCOUNT_NAME"] = "XXX"
      ENV["RSWAG_AZURE_STORAGE_ACCESS_KEY"] = "XXX"
      ENV["RSWAG_AZURE_CONTAINER"] = "bucket-name"
    end

    describe "#client" do
      it "creates Aws::S3::Resource object" do
        expect(Azure::Storage::Blob::BlobService).to receive(:create)
        subject.client
      end
    end

    describe "#upload_file" do
      it do
        allow(File).to receive(:open)
        expect(Azure::Storage::Blob::BlobService).to receive(:create) do
          double.tap do |client|
            expect(client).to receive(:create_block_blob).with("bucket-name", "key", ::File.open("file", &:read))
          end
        end
        subject.upload_file("key", "file")
      end
    end

    describe "#fetch_versions" do
      it do
        expect(Azure::Storage::Blob::BlobService).to receive(:create) do
          double.tap do |client|
            expect(client).to receive(:list_blobs).with("bucket-name", 'prefix': "schemas/app/develop_423/versions") do
              double.tap do |blobs|
                expect(blobs).to receive(:collect)
              end
            end
          end
        end
        subject.fetch_versions("423")
      end
    end

    describe "#copy_latest_version_to_root" do
      it do
        expect(Azure::Storage::Blob::BlobService).to receive(:create) do
          double.tap do |client|
            expect(client).to receive(:copy_blob).with("bucket-name", "schemas/app/develop_4334/schema.json",
                                                       "bucket-name", "key")
          end
        end
        subject.copy_latest_version_to_root("key", "4334")
      end
    end

    describe "#download_file" do
      it do
        expect(Azure::Storage::Blob::BlobService).to receive(:create) do
          double.tap do |client|
            expect(client).to receive(:get_blob).with("bucket-name", "schemas/app/develop_4334/schema.json")
          end
        end
        expect(::File).to receive(:open).with("tmp/schema.json", "wb")

        subject.download_file("4334", "tmp/schema.json")
      end
    end

    describe "#clean" do
      it do
        expect(Azure::Storage::Blob::BlobService).to receive(:create) do
          double.tap do |client|
            expect(client).to receive(:delete_blob).with("bucket-name", 1)
          end
        end

        subject.clean([1, 2, 3, 4, 5, 6])
      end
    end
  end
end
