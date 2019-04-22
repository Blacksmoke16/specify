require "db"

require "./modifiers/*"
require "./to_sql"
require "./query_builder"

# TODO: Write documentation for `Specify`
module Specify(T)
  # Default alias when none is provided.
  class_getter sp_alias : Char = 's'

  {% for name, operator in Comparison::OPERATORS %}
    def self.{{name.downcase.id}}(field : String, value : T, falias : String? = nil) : Comparison
      Comparison(T).new Comparison::OPERATORS[{{name}}], field, value, falias
    end
  {% end %}

  def self.and(*modifiers : T | BaseSpec)
    LogicOperator(T | BaseSpec).new Operator::And, modifiers.map(&.as(T | BaseSpec)).to_a
  end

  def self.or(*modifiers : T | BaseSpec)
    LogicOperator(T | BaseSpec).new Operator::Or, modifiers.map(&.as(T | BaseSpec)).to_a
  end

  def self.join(new_alias : String, on : On)
    Join(T).new new_alias, on
  end

  def self.on(left : String, right : String)
    On.new left, right
  end

  def self.select(columns : Array(String), distinct : Bool = false) : Select
    Select.new columns, distinct
  end

  # Returns an `Array(self)` with records matching the provided *spec*.
  def match(*modifiers : T | BaseSpec)
    prepare Specify(T).and(*modifiers)
  end

  # Returns an `Array(self)` with records matching the provided *spec*.
  def match(spec : LogicOperator)
    prepare spec
  end

  # :nodoc:
  private def prepare(spec : LogicOperator) : QueryBuilder
    builder = QueryBuilder(self).new spec
    builder
  end
end
