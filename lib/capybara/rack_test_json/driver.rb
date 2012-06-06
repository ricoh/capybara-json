to_inherit = Capybara.const_defined?("RackTest") ? Capybara::RackTest::Driver : Capybara::Driver::RackTest

class Capybara::RackTestJson::Driver < to_inherit
  def body
    MultiJson.decode(source) || {}
  end
  alias parsed_body body

  %w[ get delete ].each do |method|
    class_eval %{
      def #{method}(path, params = {}, env = {})
        super(path, params, env_for_rack(env))
      end
    }
  end

  %w[ post put post_json put_json ].each do |method|
    class_eval %{
      def #{method}(path, json, env = {})
        json = MultiJson.encode(json) unless json.is_a?(String)

        request_env = {
          'CONTENT_LENGTH' => json.size,
          'CONTENT_TYPE'   => "application/json; charset=\#{json.encoding.to_s.downcase}", 
          'rack.input'     => StringIO.new(json)
        }.merge(env_for_rack(env))
        
        super(path, {}, request_env)
      end
    }
  end

  %w[ post put post_json put_json ].each do |method|
    class_eval %{
      def #{method}!(url, json, headers = {})
        handle_error { #{method}(url, json, headers) }
      end
    }
  end

  def cookie(key)
    cookie_jar[key]
  end

  alias clear_all clear_cookies

  protected
  def cookie_jar
    Capybara.current_session.driver.instance_variable_get(:@_rack_mock_sessions)[:default].cookie_jar
  end

  def env_for_rack(env)
    env.inject({}) do |rack_env, (key, value)|
      env_key = key.upcase.gsub('-', '_')
      env_key = "HTTP_" + env_key unless env_key == "CONTENT_TYPE"
      rack_env[env_key] = value

      rack_env
    end
  end

  def handle_error(&block)
    yield
    raise(Capybara::Json::Error, response) if status_code >= 400
  end
end
