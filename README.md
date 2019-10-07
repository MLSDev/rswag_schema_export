# Rswag::Schema::Export

[![CircleCI](https://circleci.com/gh/MLSDev/rswag_schema_export.svg?style=svg)](https://circleci.com/gh/MLSDev/rswag_schema_export)


Export your schema.json file to AWS s3 bucket and import back after deploy. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rswag_schema_export'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rswag_schema_export
    $ rails g rswag_schema_export:install

## Set up
```diff
# config/initializers/rswag_schema_export.rb
RswagSchemaExport.configure do |c|
+  c.schemas = ['swagger/client/swagger.json', 'swagger/backoffice/swagger.json']
+  c.client = :aws
end
```
## Lifecycle
```
swaggerize -> export to cloud storage -> deploy -> import from cloud storage
```

## Export example with CI
```yaml
.gitlab-ci.yml
stages:
  - test
  - export_api_doc
  - deploy
test:
  tags:
  - shell-ruby
  before_script:
    - RAILS_ENV=test bundle exec rails db:create db:migrate
  script:
    - rspec
  artifacts:
    paths:
      - coverage/
  after_script:
    - RAILS_ENV=test bundle exec rails db:drop
rswag_schema_export:
  dependencies: []
  stage: export_api_doc
  before_script:
    - RAILS_ENV=test bundle exec rails db:create
  tags:
  - shell-ruby
  script:
  - rails db:schema:load rswag:specs:swaggerize RAILS_ENV=test
  - STAGE=develop rails rswag:schema_export
develop:
  dependencies: []
  stage: deploy
  tags:
  - shell-ruby
  script:
  - bundle exec cap develop deploy
  only:
  - develop
```


## Import example with Capistrano

```diff
# Capfile
require 'rswag_schema_export/capistrano'
```

```diff
# config/deploy.rb
+ append :linked_dirs, "swagger",
end
````


## Configuration

Set up ENVIRONMENT VARIABLES on your CI

```bash
# Required for AWS
RSWAG_AWS_ACCESS_KEY_ID='' # Example: XXXXXXXXXX
RSWAG_AWS_SECRET_ACCESS_KEY='' # Example: XXXXXXXXXXXXXXXXXXXXX
RSWAG_AWS_REGION='' # Example: us-west-1
RSWAG_AWS_BUCKET='' # Example: bucket-name

# Required for AZURE

RSWAG_AZURE_STORAGE_ACCOUNT_NAME='' # Example: XXXXX
RSWAG_AZURE_STORAGE_ACCESS_KEY='' # Example: XXXXXXXXXXXXXXXXXXXXX
RSWAG_AZURE_CONTAINER='' # Example: continter-name

# Optional
STAGE='' # Default: develop
APP_NAME='' # Default: app
```

## Gitlab Variables

![image](https://user-images.githubusercontent.com/2664467/64493266-bc699f00-d286-11e9-8827-e99d0eada9ce.png)

## rswag-api
```diff
# config/initializers/rswag_api.rb
Rswag::Api.configure do |c|
+  c.swagger_root = Rails.root.to_s + '/swagger'
end
```

## Contributing

1. Fork it ( link )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The MIT License

## About MLSDev

![MLSdev][logo]

The repo is maintained by MLSDev, Inc. We specialize in providing all-in-one solution in mobile and web development. Our team follows Lean principles and works according to agile methodologies to deliver the best results reducing the budget for development and its timeline.

Find out more [here][mlsdev] and don't hesitate to [contact us][contact]!

[mlsdev]:  https://mlsdev.com
[contact]: https://mlsdev.com/contact_us
[logo]:    https://raw.githubusercontent.com/MLSDev/development-standards/master/mlsdev-logo.png "Mlsdev"

