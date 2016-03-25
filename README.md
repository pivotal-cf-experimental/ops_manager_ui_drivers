# OpsManagerUIDrivers [![Build Status](https://travis-ci.org/pivotal-cf-experimental/ops_manager_ui_drivers.svg?branch=master)](https://travis-ci.org/pivotal-cf-experimental/ops_manager_ui_drivers)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ops_manager_ui_drivers`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ops_manager_ui_drivers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ops_manager_ui_drivers

## Usage

Hypothetical usage example for driving a local Ops Manager instance:

```ruby
require 'bundler/setup'
require 'rspec'
require 'capybara'
require 'capybara/webkit'
require 'capybara/dsl'

require 'ops_manager_ui_drivers'

RSpec.configure do |config|
  config.fail_fast = true

  Capybara.configure do |c|
    c.default_driver = :webkit
  end

  Capybara::Webkit.configure do |c|
    c.allow_url('fonts.googleapis.com')
    c.allow_url('localhost')
  end
end

RSpec.describe 'Configuring localhost', order: :defined, type: :integration do
  include Capybara::DSL
  include OpsManagerUiDrivers::PageHelpers

  let(:current_ops_manager) { om_1_7('http://localhost:3000') }

  it 'sets the certs' do
    current_ops_manager.setup_page.setup_or_login(
      user: 'admin',
      password: 'password',
    )

    expect(page).to have_content('Installation Dashboard')

    configuration = OpsManagerUiDrivers::Version18::ProductConfiguration.new(browser: self, product_name: 'example-product')
    selector_form = configuration.product_form('example_selector_form')
    selector_form.open_form
    
    selector_form.fill_in_selector_property(selector_input_reference:'.properties.example_selector', selector_name:'example_selector', selector_value: 'Some Option', sub_field_answers: [])
    selector_form.generate_self_signed_cert(
      '*.example.com',
      '.properties.example_selector.some_option.some_rsa_cert',
      '.properties.example_selector',
      'some_option'
    )
    selector_form.save_form
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/pivotal-cf-experimental/ops_manager_ui_drivers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
