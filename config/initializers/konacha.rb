require "tilt/coffee"

if defined?(Konacha)
  Capybara.register_driver :slow_poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 2.minutes, debug: true)
  end
  Konacha.configure do |config|
    require "capybara/poltergeist"
    config.driver = :slow_poltergeist
  end
end
