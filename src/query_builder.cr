module Specify(T)
  class QueryBuilder(T)
    property select_part : String = "*"
    getter joins : Array(String) = [] of String
    getter where_part : String? = ""
    getter params : Array(DB::Any) = [] of DB::Any

    def initialize(spec, @klass : T.class = T)
      @where_part = spec.get_filter self
    end

    def to_sql : String
      String.build do |str|
        str << "SELECT "
        str << select_part
        str << " FROM "
        str << "#{T.table} #{Specify.sp_alias}"
        str << (joins.size.zero? ? "" : ' ')
        str << joins.join(' ')
        if (w = where_part) && !w.empty?
          str << ' '
          str << "WHERE "
          str << w
        end
        str << ';'
      end
    end
  end
end
