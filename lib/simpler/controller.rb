require_relative 'view'

module Simpler
  class Controller

    attr_accessor :headers
    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @headers = {}
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      send(action)
      set_default_headers
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      render_type = @request.env['simpler.template'] ? header_type : 'html'

      @response['Content-Type'] = "text/#{render_type}"
      @response['Path_info'] = @request.path_info
      set_headers
    end

    def set_headers
      @headers.each { |key, value| @response[key] = value }
    end

    def write_response
      body = @request.env['simpler.template'] ? render_body_by_type : render_body
      
      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def header_type
      @request.env['simpler.template'].keys[0].to_s
    end

    def render_body_by_type
      @request.env['simpler.template'].values[0].to_s
    end

    def status(template)
      @response.status = template
    end
  end
end
