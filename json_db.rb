require 'json'
require './ghost_hash'

class JsonDb

  ALLOWED_SUFFIXES = %w[=].freeze
  
  def initialize(json_filename)
    @json_filename = json_filename
    # create dynamic class because we send unique property of current instance to many custom hash instances
    @ghost_hash_class = Class.new(GhostHash)
    @ghost_hash_class.json_filename = @json_filename   # we need send it to any instances of hash class
    @ghost_hash_class.json_root = self                 # and this one too
  end

  attr_reader :json_filename
  
  def data
    @data ||= @ghost_hash_class.new(JSON.parse(IO.read(json_filename)))
  end
  
  private
  
  # Use this method to store updated properties on disk
  def serialize
    IO.write(json_filename, data.to_json)
  end

  def method_missing(method_name, *args, &block)
    name, suffix = method_name_and_suffix(method_name.to_s)
    case suffix
    when '='.freeze
      assign_property(name, args.first)
    else
      data[method_name.to_s]
    end
  end

  def method_name_and_suffix(method_name)
    method_name = method_name.to_s
    if method_name.end_with?(*ALLOWED_SUFFIXES)
      [method_name[0..-2], method_name[-1]]
    else
      [method_name[0..-1], nil]
    end
  end

  def assign_property(name, value)
    data[name] = value
    serialize
    value
  end
  
end
