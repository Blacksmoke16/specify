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

    def add(spec : T | BaseSpec)
      @members << spec
    end

    def get_filter(builder : QueryBuilder) : String
      comparison_count : Int32 = @members.count { |m| !m.is_a?(Join) }
      String.build do |str|
        str << '(' if comparison_count > 1
        @members.map do |m|
          case m
          when Specify::Modifier  then m.modify builder
          when Specify::Filter    then m.get_filter builder
          when Specify::QuerySpec then m.get_spec.get_filter builder
          end
        end.compact.join " #{@operator.to_sql} ", str
        str << ')' if comparison_count > 1
      end
    end
  end
end
