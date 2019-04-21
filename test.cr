class String
  def to_sql
    String.build do |str|
      str << '\''
      str << self
      str << '\''
    end
  end
end

struct Number
  def to_sql
    self
  end
end

struct Nil
  def to_sql
    String.build do |str|
      str << 'N' << 'U' << 'L' << 'L'
    end
  end
end

struct Bool
  def to_sql
    self ? 1 : 0
  end
end

class Array(T)
  def to_sql : String
    String.build do |str|
      str << '('
      str << self.map(&.to_sql).join(',')
      str << ')'
    end
  end
end

# Base structs
abstract struct BaseSpec; end

abstract struct Modifier < BaseSpec
  abstract def modify(builder : QueryBuilder)
end

abstract struct Filter < BaseSpec
  abstract def get_filter(builder : QueryBuilder) : String
end

abstract struct QuerySpec
  abstract def get_spec : BaseSpec
end

#########
# Logic #
#########

enum Operator
  And
  Or

  # Returns the operator string.
  def to_sql : String
    to_s.upcase
  end
end

struct LogicOperator(T) < Filter
  def initialize(@operator : Operator, @members : Array(T | BaseSpec)); end

  def get_filter(builder : QueryBuilder) : String
    String.build do |str|
      str << '(' if @members.size > 1
      @members.map do |m|
        case m
        when Modifier  then m.modify builder
        when Filter    then m.get_filter builder
        when QuerySpec then m.get_spec.get_filter builder
        end
      end.compact.join " #{@operator.to_sql} ", str
      str << ')' if @members.size > 1
    end
  end
end

##############
# Comparison #
##############

struct Comparison(T) < Filter
  OPERATORS = {
    "EQ"       => "=",
    "NEQ"      => "<>",
    "GT"       => ">",
    "LT"       => "<",
    "GTE"      => ">=",
    "LTE"      => "<=",
    "LIKE"     => "LIKE",
    "NOT_LIKE" => "NOT LIKE",
    "IN"       => "IN",
    "NOT_IN"   => "NOT IN",
  }

  def initialize(@operator : String, @field : String, @value : T, @alias : String? = nil)
    @alias = Specify.sp_alias if @alias.nil?
  end

  def get_filter(builder : QueryBuilder) : String
    builder.params << @value.to_sql
    String.build do |str|
      str << @alias << '.' << @field << ' ' << @operator << ' ' << '?'
    end
  end
end

###########
# Builder #
###########

class QueryBuilder(T)
  property select_part : String = "*"
  property joins : Array(String) = [] of String
  property where_part : String? = ""
  property params : Array(Int32 | String) = [] of Int32 | String

  def initialize(spec, @klass : T.class = T)
    @where_part = spec.get_filter self
  end

  def to_sql : String
    String.build do |str|
      str << "SELECT " << select_part << " FROM " << "#{T.table} #{Specify.sp_alias} " << joins.join(' ') << ' ' << "WHERE " << where_part << ';'
    end
  end
end

struct On < Filter
  def initialize(@left : String, @right : String); end

  def get_filter(builder : QueryBuilder) : String
    String.build do |str|
      str << ' ' << "ON" << ' ' << @left << " = " << @right
    end
  end
end

struct Join(T) < Modifier
  INNTER = "INNER "
  OUTER  = "OUTER "
  ALL    = ""

  def initialize(@newAlias : String, @on : On, @type : String = ALL)
  end

  def modify(builder : QueryBuilder) : Nil
    builder.joins << String.build do |str|
      str << @type << "JOIN " << T.table << ' ' << @newAlias << @on.get_filter builder
    end
  end
end

module Specify(T)
  class_property sp_alias : String = "spec"

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

  def match(*modifiers : T | BaseSpec)
    prepare *modifiers
  end

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

struct IsActive < QuerySpec
  def get_spec : BaseSpec
    Specify.and(
      Specify(Bool).eq("is_active", true)
    )
  end
end

struct IsAdmin < QuerySpec
  def get_spec : BaseSpec
    Specify.and(
      Specify(String).eq("name", "Joe"),
      Specify(Bool).eq("is_admin", true)
    )
  end
end

struct HasRole < QuerySpec
  def initialize(@role : String); end

  def get_spec : Modifier
    spec = Specify.or(
      Specify(String).eq(field: "role", value: @role)
    )

    if @role == "ROLE_ADMIN"
      spec.add IsAdmin.new
    end
    spec
  end
end

class Klass
  def self.table
    "classes"
  end

  extend Specify(IsAdmin | IsActive)
end

class User
  def self.table
    "users"
  end

  extend Specify(BaseSpec)
end

id = "123"

q = Klass.match(
  # Specify(User).join("j", Specify.on("spec.id", "j.user_id")),
  Specify(Int32).eq("id", id),
  # Specify.like("name", "foo"),
  # IsActive.new,
  # IsAdmin.new # Reusable
)

puts q.to_sql

# require "spec"

# # Can test the returned spec, so changes that would affect the query could be caught.
# it "should be valid" do
#   spec = IsActive.new.get_spec
#   spec.should eq Specify.and(Specify(Bool).eq("is_active", true))
# end

# # puts Operator::And.to_sql
