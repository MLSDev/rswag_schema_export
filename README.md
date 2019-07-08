# Rswag::Schema::Export


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

## Usage

Gem contains two rake tasks:

    $ rake rswag:schema_export
    $ rake rswag:schema_import

## Lifecicle
```bash
# Pipeline
stages:
  staging:
    - rspec spec
    - rails rswag:specs:swaggerize
    - STAGE=staging rails rswag:schema_export
    - cap staging deploy
    - STAGE=staging rails rswag:schema_import
```

## Capistrano

```diff
# config/deploy.rb
+ folders = %w[tmp/swagger]
namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    
    end
  end
+  after :finishing, 'rswag:schema_import'
end
````

## Configuration

Set up ENVIRONMENT VARIABLES on your CI

```bash
# Required
RSWAG_SCHEMA_PATH='' # Example: tmp/swagger/swagger.json
RSWAG_ACCESS_KEY_ID='' # Example: XXXXXXXXXX
RSWAG_SECRET_ACCESS_KEY='' # Example: XXXXXXXXXXXXXXXXXXXXX
RSWAG_REGION='' # Example: us-west-1
RSWAG_BUCKET='' # Example: bucket-name

# Optional
STAGE='' # Default: develop
APP_NAME='' # Default: app
```

## Gitlab Variables

![image](https://user-images.githubusercontent.com/2664467/60773983-c69bdf80-a115-11e9-9f46-57d835ba4561.png)


## rswag-api
```diff
# config/initializers/rswag_api.rb
Rswag::Api.configure do |c|
+  c.swagger_root = Rails.root.to_s + '/tmp/swagger'
end
```

## rswag-specs
```diff
# spec/swagger_helper.rb

RSpec.configure do |config|
+  config.swagger_root = Rails.root.to_s + '/tmp/swagger'
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

