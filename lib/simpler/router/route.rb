module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path)
        @method == method && check_correct_path(path)
      end

      def params(env)
        request = Rack::Request.new(env)
        response = Rack::Response.new
        created_params = create_params(env['PATH_INFO'])
        created_params.each_with_index { |param, i| request.update_param(param[i], param[i+1]) }
      end

      private

      def create_params(path_info)
        path = extract_path(@path)
        request = extract_path(path_info)
        result = {}

        combined_path_array = path.zip(request)

        combined_path_array.each do |value|
          if value[0] != value[1]
            value[0] = value[0].delete(':').to_sym
            result[value[0]] = value[1]
          end
        end

        result
      end

      def extract_path(path)
        path_array = path.split('/')
        path_array.delete("")
        path_array
      end

      def check_correct_path(path)
        check_correct_params_count(path) && path.match(path_regexp)
      end

      def check_correct_params_count(path)
        path.split('/').size == @path.split('/').size
      end

      def path_regexp
        route = extract_path(@path)
        route.map { |param| params?(param) ? '[[:alnum:]]' : param }.join('/')
      end

      def params?(param)
        param.start_with?(':')
      end
    end
  end
end
