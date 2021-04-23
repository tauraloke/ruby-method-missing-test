require 'hashie'

class GhostHash < Hashie::Mash
  class << self
    attr_accessor :json_filename, :json_root, :name
  end

  def initialize(hash)
    result = hash.dup
    result.each do |key, value|
      result[key] = value
    end
    result
  end

  # redeclare Mash method for updating json file after property' changing
  def assign_property(name, value)
    super(name, value)
    serialize_root
    value
  end

  def convert_value(val, duping = false) #:nodoc:
    case val
    when self.class
      val.dup
    when Hash
      duping ? val.dup : val
    when ::Hash
      val = val.dup if duping
      new_class = Class.new(self.class)
      print 'getting new class', new_class, '+++++++'
      new_class.new(val)
    when ::Array
      Array.new(val.map { |e| convert_value(e) })
    else
      val
    end
  end

  private

  def serialize_root
    IO.write(self.class.json_filename, self.class.json_root.data.to_json)
  end

end
