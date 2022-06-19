require 'logger'

class AppLogger
  def initialize(app, **options)
    @app = app
    @logger = Logger.new(options[:logdev]) 
  end 

  def call(env)
    status, headers, response = @app.call(env)
    @logger.info(create_info(env, status, headers))
    [status, headers, response]
  end

  private

  def create_info(env, status, headers)
    {
      Request: "#{env['REQUEST_METHOD']} #{env['PATH_INFO']}?#{env['QUERY_STRING']}",
      Handler: "#{env['simpler.controller'].class}##{env['simpler.action']}",
      Parameters: "#{env['simpler.parameters']}",
      Response: "#{status} [#{headers['Content-Type']}] #{env['simpler.template_path']}"
    }
  end
end
