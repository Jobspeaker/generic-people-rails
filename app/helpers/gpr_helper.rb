module GprHelper
  
  def method_missing method, *args, &block
    method.to_s.end_with?('_path', '_url') and main_app.respond_to?(method) ? main_app.send(method, *args) : super
  end

end