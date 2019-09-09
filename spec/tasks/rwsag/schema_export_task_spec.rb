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
      allow(RswagSchemaExport.config).to receive(:schemas).and_return(["1.json"])
      ENV["RSWAG_AWS_ACCESS_KEY_ID"] = "XXX"
      ENV["RSWAG_AWS_SECRET_ACCESS_KEY"] = "XXX"
      ENV["RSWAG_AWS_REGION"] = "us-east-1"
      ENV["RSWAG_AWS_BUCKET"] = "bucket-name"
    end

    context "not found schema file" do
      it do
        allow(File).to receive(:file?).and_return(false)
        expect { run_rake_task }.to raise_error SystemExit
      end
    end

    context "Upload latest version to the cloud" do
      it do
        allow(File).to receive(:file?).and_return(true)
        allow(Time).to receive_message_chain(:now, :getutc, :iso8601).and_return("2019-09-09T20:14:08Z")
        expect(::RswagSchemaExport::Client).to receive(:new) do
          double.tap do |client|
            allow(client).to receive(:app_name).and_return("app")
            allow(client).to receive(:stage).and_return("develop")
            expect(client).to receive(:upload_file)
              .with("schemas/app/develop_1_json/versions/2019-09-09T20:14:08Z.json", "1.json")
          end
        end
        run_rake_task
      end
    end
  end
end
