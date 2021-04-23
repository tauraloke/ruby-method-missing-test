require 'json'
require 'active_support/inflector'
#
require 'pry'

class JsonDb

  ALLOWED_SUFFIXES = %w[=].freeze
  attr_accessor :json_filename, :root_json_db

  class << self
    attr_accessor :name
  end

  def initialize(json_filename)
    @json_filename = json_filename
    @root_json_db = self
  end

  def self.create_child_node(data, classname = nil, root_json_db = nil)
    dynamic_class = Class.new(self.class)
    dynamic_class.class.name = classname
    child_node = dynamic_class.new(data, classname, root_json_db)
    child_node.json_filename = root_json_db.json_filename
    child_node.root_json_db = root_json_db
    child_node.data = redeclare_fields(data)
    return child_node
  end
  
  def data
    @data ||= redeclare_fields(JSON.parse(IO.read(@json_filename)))
  end

  def data=(hash)
    @data = hash
  end

  def [](field)
    data[field.to_s]
  end

  def []=(field, value)
    value = assign_property(field, value)
    serialize
    value
  end

  def to_json(options)
    self.data.to_json(options)
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
      self.create_child_node(data, new_name, self.root_json_db)
    when Array.to_s
      data.map do |row|
        binding.pry
        new_name = self.key_to_class_name(key)
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
