module Snorby
  module Plugins
    module Helpers
      
      def standardize_parameters(params={}, plugin_params={})  
        
        params.each { |key, value| params.delete(key.to_sym) unless plugin_params.has_key?(key.to_sym) }
        plugin_params.each { |key, value| params.delete(key.to_sym) if params[key.to_sym] == '' }
        
        params[:start_time] = params_to_datetime_object(params[:start_time]) unless (params[:start_time].kind_of?(Time) || params[:start_time].kind_of?(DateTime))
        params[:end_time] = params_to_datetime_object(params[:end_time]) unless (params[:end_time].kind_of?(Time) || params[:end_time].kind_of?(DateTime))
        
        param_keys = params.keys
        
        param_keys.each do |key,value|
          if plugin_params.include?(key.to_sym)
            old = params.delete(key.to_sym)
            params[plugin_params[key.to_sym]] = old
          end
        end
        
        params
      end
      
      def convert_to_params
        url = []; @params.each { |k,v| url << "#{k}=#{v}" }; url.join('&')
      end
      
      def params_to_datetime_object(params)
        Time.mktime(params['(1i)'], params['(2i)'], params['(3i)'], params['(4i)'], params['(5i)'])
      end
      
    end
  end
end
