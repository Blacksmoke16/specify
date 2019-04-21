require "./modifier"

module Specify
  struct Select < Modifier
    def initialize(@fields : Array(String), @distinct : Bool = false); end

    def modify(builder : QueryBuilder) : Nil
      builder.select_part = String.build do |str|
        str << "DISTINCT " if @distinct
        str << @fields.join(", ")
      end
    end
  end
end
