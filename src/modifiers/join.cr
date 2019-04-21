require "./modifier"

module Specify(T)
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
end
