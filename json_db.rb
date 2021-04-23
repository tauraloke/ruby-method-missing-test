require 'json'
require 'active_support/inflector'
#
#require 'pry'

class JsonDb

  ALLOWED_SUFFIXES = %w[=].freeze
  attr_reader :json_filename

  class << self
    attr_accessor :name
  end

  def initialize(data, classname = nil, root_json_db = nil)
    @is_root = data.class.name == String.to_s
    if @is_root
      @json_filename = data
      self.class.name = 'Root'
      @root_json_db = self
    else
      @json_filename = root_json_db.json_filename
      self.class.name = classname
      @root_json_db = root_json_db
      @data = redeclare_fields(data)
    end
  end
  
  def data
    unless @data.present?
      @data = redeclare_fields(JSON.parse(IO.read(@json_filename)))
    end
    @data
  end

  def [](field)
    data[field.to_s]
  end

  def []=(field, value)
    value = assign_property(field, value)
    serialize
    value
  end
  
  private

  def redeclare_fields(hash)
    hash.each do |key, value|
      hash[key] = redeclare_object(value, key)
    end
    hash
  end

  def redeclare_object(data, key, new_name = nil)
    case data.class.name
    when Hash.to_s
      self.class.new(data, new_name, self)
    when Array.to_s
      data.map do |row|
        new_name = key_to_class_name(key)
        row = redeclare_object(row, key, new_name)
      end
    else
      data
    end
  end

  def key_to_class_name(key)
    ActiveSupport::Inflector.singularize(key).capitalize
  end
  
  # Use this method to store updated properties on disk
  def serialize
    IO.write(json_filename, @root_json_db.data.to_json)
  end

  def method_missing(method_name, *args, &block)
    name, suffix = method_name_and_suffix(method_name.to_s)
    case suffix
    when '='.freeze
      value = assign_property(name, args.first)
      serialize
      value
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
  end
  
end
