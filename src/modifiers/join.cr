require "./modifier"

module Specify(T)
  struct Join(T) < Modifier
    INNTER = "INNER "
    OUTER  = "OUTER "
    ALL    = ""

    def initialize(@new_alias : String, @on : On, @type : String = ALL)
    end

    def modify(builder : QueryBuilder) : Nil
      builder.joins << String.build do |str|
        str << @type << "JOIN " << T.table << ' ' << @new_alias << @on.get_filter builder
      end
    end
  end
end
