require "./filter"

module Specify(T)
  struct On < Filter
    def initialize(@left : String, @right : String); end

    def get_filter(builder : QueryBuilder) : String
      String.build do |str|
        str << ' ' << "ON" << ' ' << @left << " = " << @right
      end
    end
  end
end
