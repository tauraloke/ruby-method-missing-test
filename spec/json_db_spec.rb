require "./json_db"

RSpec.describe JsonDb do
  
  before(:example) do
    system("cp ./db.json /tmp/db.json")
    @db = JsonDb.new("/tmp/db.json")
  end
  
  # Sample implementation with :method_missing
  it "only reads top level properties" do
    expect(@db.name).to eq(@db.data["name"])
    expect(@db.created_at).to eq(@db.data["created_at"])
  end

  # Complexity Level #1
  it "reads properties on all levels" do
    expect(@db.companies[0].employees[0].first_name).to eq(@db.data["companies"][0]["employees"][0]["first_name"])
  end

  # Complexity Level #2
  it "writes properties on all levels" do
    @db.companies[0].employees[0].first_name = "Nick"
    expect(@db.companies[0].employees[0].first_name).to eq("Nick")
    expect(JSON.parse(IO.read(@db.json_filename))["companies"][0]["employees"][0]["first_name"]).to eq("Nick")
  end

  # Complexity Level #3
  it "reads instances of dynamically defined classes on all levels" do
    expect(@db.created_at.class.name).to eq("String")
    expect(@db.companies[0].class.name).to eq("Company")
    expect(@db.companies[0].name.class.name).to eq("String")
    expect(@db.companies[0].employees[0].class.name).to eq("Employee")
    expect(@db.companies[0].employees[0].first_name.class.name).to eq("String")
  end

end