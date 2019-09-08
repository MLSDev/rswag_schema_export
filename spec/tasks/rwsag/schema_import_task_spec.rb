require "rake"
describe "rswag:schema_import" do
  before :all do
    Rake.application.rake_require "tasks/rswag_tasks"
    Rake::Task.define_task(:environment)
  end
  describe do
    let(:run_rake_task) do
      Rake::Task["rswag:schema_import"].reenable
      Rake.application.invoke_task "rswag:schema_import"
    end

    before do
      ENV["RSWAG_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_REGION"] = "us-east-1"
      ENV["RSWAG_AWS_BUCKET"] = "bucket-name"
    end

    it "download schema from s3 bucket" do
      s3 = double(:s3)
      object = double(:object, copy_to: nil, download_file: nil, delete: nil)
      expect(Aws::S3::Resource).to receive(:new).and_return(s3)
      bucket = double(:bucket, object: nil)
      expect(s3).to receive(:bucket).and_return(bucket)
      expect(bucket).to receive_message_chain(:objects, :collect).and_return(%w[1 2 3 4 5 6])
      expect(bucket).to receive(:object).exactly(3).and_return(object)
      run_rake_task
    end
  end
end
