require 'hashie'

class GhostHash < Hashie::Mash
  class << self
    attr_accessor :json_filename, :json_root
  end

  # redeclare Mash method for updating json file after property' changing
  def assign_property(name, value)
    super(name, value)
    serialize_root
    value
  end

  private

  def serialize_root
    IO.write(self.class.json_filename, self.class.json_root.data.to_json)
  end

end
