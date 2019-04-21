require "./filter"

module Specify(T)
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
          when Specify::Modifier  then m.modify builder
          when Specify::Filter    then m.get_filter builder
          when Specify::QuerySpec then m.get_spec.get_filter builder
          end
        end.join " #{@operator.to_sql} ", str
        str << ')' if @members.size > 1
      end
    end
  end
end
