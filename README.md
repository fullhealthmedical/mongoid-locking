# Mongoid::Locking

It adds Optimistic Locking to `Mongoid::Document` objects.

This gem is inspired in the [ActiveRecord::Locking](https://api.rubyonrails.org/v7.0.3.1/classes/ActiveRecord/Locking/Optimistic.html)
module.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add mongoid-locking

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install mongoid-locking

## Usage

- Include `Mongoid::Locking` module

```ruby
  class Order
    include Mongoid::Document
    include Mongoid::Locking
  end
```

- Handle `Mongoid::StaleObjectError` when performing updates

```ruby
  # ...
  def update_order
    order.update(attributes)
  rescue Mongoid::StaleObjectError => e
    add_error("This order has been changed ...")
  end
end
```

- Use `with_locking` to automatically handle `Mongoid::StaleObjectError`

By default, `with_locking` will retry the update 3 times in case of a
`Mongoid::StaleObjectError`.

```ruby
  def process_with_locking
    order.with_locking do
      # Ensure the block is idempotent
      # Reload object(s) within the block to get the latest changes
      order.reload
      # Your code here
      # ...
    end
  end
```

Remember to refresh the object

Adjust the `max_retries`` parameter to control the number of retry attempts in
case of a `Mongoid::StaleObjectError`.

```ruby
  # ...
  def update_order
    order.with_locking(max_retries: 2) do
      order.update(attributes)
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fullhealthmedical/fhweb/mongoid-locking. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fullhealthmedical/fhweb/mongoid-locking/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mongoid::Locking project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fullhealthmedical/fhweb/mongoid-locking/blob/master/CODE_OF_CONDUCT.md).

## Version Compability

| Gem version | Mongoid version |
| -------- | ------- |
| 0.1.2 | >= 6.0, < 7.2 |
| 1.0.0 | ~> 7.2.0 |
| ~> 1.1.0 | ~> 7.2 |
