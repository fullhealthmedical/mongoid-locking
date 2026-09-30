## [2.1.0]

- Change: `with_locking` retries back off with full jitter in milliseconds
  (0.1s base, 1s cap) instead of 2–9 seconds; configurable through
  `Mongoid::Locking.backoff_base` and `Mongoid::Locking.backoff_cap`

## [1.3.0]

- Add: delay between retries for `with_locking` method [#8](https://github.com/fullhealthmedical/mongoid-locking/pull/8)

## [1.2.0]

- Add: with_locking method [#6](https://github.com/fullhealthmedical/mongoid-locking/pull/6)

## [1.1.1]

- Fix: Fix update embedded association [#5](https://github.com/fullhealthmedical/mongoid-locking/pull/5)

## [1.1.0]

- Add: Support for Mongoid 7.3 [#3](https://github.com/fullhealthmedical/mongoid-locking/pull/3)

## [0.1.0] - 2022-08-03

- Initial release

Supports Mongoid 6
