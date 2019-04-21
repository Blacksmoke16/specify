module Specify(T)
  class QueryBuilder(T)
    property select_part : String = "*"
    property joins : Array(String) = [] of String
    property where_part : String? = ""
    property params : Array(DB::Any) = [] of DB::Any

    def initialize(spec, @klass : T.class = T)
      @where_part = spec.get_filter self
    end

    def to_sql : String
      String.build do |str|
        str << "SELECT " << select_part << " FROM " << "#{T.table} #{Specify.sp_alias}" << (joins.size.zero? ? "" : ' ') << joins.join(' ') << ' ' << "WHERE " << where_part << ';'
      end
    end
  end
end
