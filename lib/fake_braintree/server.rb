require 'capybara'
require 'capybara/server'
require 'rack/handler/thin' if RUBY_PLATFORM != 'java'
require 'rack/handler/puma' if RUBY_PLATFORM == 'java'

class FakeBraintree::Server
  def boot
    with_thin_runner do
      server = Capybara::Server.new(FakeBraintree::SinatraApp)
      server.boot
      ENV['GATEWAY_PORT'] = server.port.to_s
    end
  end

  private

  def with_thin_runner
    default_server_process = Capybara.server
    Capybara.server do |app, port|
      if RUBY_PLATFORM == 'java'
        Rack::Handler::Puma.run(app, :Port => port)
      else
        Rack::Handler::Thin.run(app, :Port => port)
      end
    end
    yield
  ensure
    Capybara.server(&default_server_process)
  end
end
