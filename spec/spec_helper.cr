require "spec"
require "../src/specify"

# Asserts the given `LogicalOperator` produce the correct *statement* and has the correct *params*.
def assert_filter(statement : String, params : Array(Array(DB::Any) | DB::Any), select_part : String = "SELECT * FROM contacts s", klass : T.class = Contact, &block : Nil -> Specify::LogicOperator) forall T
  qb = Specify::QueryBuilder(T).new yield nil
  sql = qb.to_sql.split("WHERE")
  sql.first.strip.should eq select_part
  if where = sql[1]?
    where.strip.should eq statement
  end
  qb.params.should eq params
end

struct HasName < Specify::QuerySpec
  def initialize(@name : String); end

  def get_spec : Specify::BaseSpec
    Specify.and(
      Specify(String).eq("name", @name)
    )
  end
end

struct IsActive < Specify::QuerySpec
  def get_spec : Specify::BaseSpec
    Specify.and(
      Specify(Bool).eq("is_active", true)
    )
  end
end

class User
  def self.table
    "users"
  end

  extend Specify(Specify::QuerySpec)
end

class Post
  def self.table
    "posts"
  end

  extend Specify(Specify::QuerySpec)
end

class Setting
  def self.table
    "settings"
  end

  extend Specify(Specify::QuerySpec)
end

class Contact
  def self.table
    "contacts"
  end

  extend Specify(Specify::QuerySpec)
end
