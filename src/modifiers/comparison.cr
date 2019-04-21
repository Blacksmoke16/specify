require "./filter"

module Specify(T)
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

    def initialize(@operator : String, @column : String, @value : T, @alias : String? = nil)
      @alias = Specify.sp_alias if @alias.nil?
    end

    def get_filter(builder : QueryBuilder) : String
      builder.params << @value.to_sql
      String.build do |str|
        str << @alias << '.' << @column << ' ' << @operator << ' ' << '?'
      end
    end
  end
end
