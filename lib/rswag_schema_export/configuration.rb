module RswagSchemaExport
  class Configuration
    attr_accessor :schemas, :client

    def initialize
      @client = :aws
    end
  end
end
