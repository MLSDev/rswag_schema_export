describe RswagSchemaExport::Configuration do
  it "default client value :aws" do
    expect(subject.client).to eq(:aws)
  end
end
