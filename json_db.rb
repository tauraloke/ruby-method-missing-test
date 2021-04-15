require 'json'
class JsonDb
  
  def initialize(json_filename)
    @json_filename = json_filename
  end

  attr_reader :json_filename
  
  def data
    @data ||= JSON.parse(IO.read(@json_filename))
  end
  
  private
  
  # Use this method to store updated properties on disk
  def serialize
    IO.write(json_filename, data)
  end

  def method_missing(method_name, *args, &block)
    data[method_name.to_s]
  end
  
end