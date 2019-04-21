require "db"

require "./modifiers/*"
require "./to_sql"
require "./query_builder"

# TODO: Write documentation for `Specify`
module Specify(T)
  class_property sp_alias : Char = 's'

  {% for name, operator in Comparison::OPERATORS %}
    def self.{{name.downcase.id}}(field : String, value : T, falias : String? = nil) : Comparison
      Comparison(T).new Comparison::OPERATORS[{{name}}], field, value, falias
    end
  {% end %}

  def self.and(*modifiers : T | BaseSpec)
    LogicOperator(T | BaseSpec).new Operator::And, modifiers.map(&.as(T | BaseSpec)).to_a
  end

  def self.join(new_alias : String, on : On)
    Join(T).new new_alias, on
  end

  def self.on(left : String, right : String)
    On.new left, right
  end

  # Returns an `Array(self)` with records matching the provided *spec*.
  def match(*modifiers : T | BaseSpec)
    prepare *modifiers
  end

  # Returns an `Array(self)` with records matching the provided *spec*.
  def match(spec : LogicOperator)
    prepare spec
  end

  # :nodoc:
  private def prepare(spec : LogicOperator(T | BaseSpec)) : QueryBuilder
    builder = QueryBuilder(self).new spec
    builder
  end

  # :nodoc:
  private def prepare(*matchers : T | BaseSpec)
    prepare Specify(T).and(*matchers)
  end
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

class Contact
  def self.table
    "contacts"
  end

  extend Specify(HasName)
end

require "sqlite3"

query = Contact.match(
  Specify(Int32).gte("age", 30),
  HasName.new("Foo"),
  IsActive.new
)

puts query.to_sql, query.params

DB.open "sqlite3://./data.db" do |db|
  # puts "contacts:"
  db.query query.to_sql, query.params do |rs|
    puts "#{rs.column_name(0)} (#{rs.column_name(1)})"
    # => name (age)
    rs.each do
      puts "#{rs.read(String)} #{rs.read(Int32)}"
    end
  end
end
