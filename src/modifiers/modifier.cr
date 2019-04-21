module Specify(T)
  # Base struct for a `Modifier`.  Alters the
  # query itself.  Such as adding joins, or changing the selected columns.
  abstract struct Modifier < BaseSpec
    abstract def modify(builder : QueryBuilder)
  end
end
