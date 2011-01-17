module Snorby
  module Plugins
    module Helpers
      
      def standardize_parameters(params={}, plugin_params={})  
        
        plugin_params.each do |key, value|
          params.delete(key.to_sym) if params[key.to_sym] == ''
        end
        
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
      
    end
  end
end