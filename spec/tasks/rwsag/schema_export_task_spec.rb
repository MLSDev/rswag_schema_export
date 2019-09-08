require "rake"
describe "rswag:schema_export" do
  before :all do
    Rake.application.rake_require "tasks/rswag_tasks"
    Rake::Task.define_task(:environment)
  end
  describe do
    let(:run_rake_task) do
      Rake::Task["rswag:schema_export"].reenable
      Rake.application.invoke_task "rswag:schema_export"
    end

    before do
      ENV["RSWAG_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_REGION"] = "us-east-1"
      ENV["RSWAG_AWS_BUCKET"] = "bucket-name"
    end

    context "not found schema file" do
      it do
        allow(File).to receive(:file?).and_return(false)
        expect { run_rake_task }.to raise_error SystemExit
      end
    end

    context "upload schema to s3 bucket" do
      it do
        allow(File).to receive(:file?).and_return(true)
        s3 = double(:s3)
        object = double(:object, upload_file: nil)
        bucket = double(:bucket, object: nil)
        expect(Aws::S3::Resource).to receive(:new).and_return(s3)
        expect(s3).to receive(:bucket).and_return(bucket)
        expect(bucket).to receive(:object).and_return(object)

        run_rake_task
      end
    end
  end
end
