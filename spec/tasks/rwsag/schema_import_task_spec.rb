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
      allow(RswagSchemaExport.config).to receive(:schemas).and_return(["1.json"])
      ENV["RSWAG_AWS_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_SECRET_ACCESS_KEY"] = "XXX"
      ENV["RSWAG_AWS_REGION"] = "us-east-1"
      ENV["RSWAG_AWS_BUCKET"] = "bucket-name"
    end

    it "download schema from s3 bucket" do
      expect(::RswagSchemaExport::Client).to receive(:new) do
        double.tap do |client|
          allow(client).to receive(:app_name).and_return("app")
          allow(client).to receive(:stage).and_return("develop")
          expect(client).to receive(:fetch_versions).with("1_json").and_return(["5.json", "6.json"])
          expect(client).to receive(:copy_latest_version_to_root).with("6.json", "1_json")
          expect(client).to receive(:download_file).with("1_json", "1.json")
          expect(client).to receive(:clean).with(["5.json", "6.json"])
        end
      end

      run_rake_task
    end
  end
end
