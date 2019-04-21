module Specify(T)
  # Base struct for a `Filter`.  WHERE statement stuff.
  abstract struct Filter < BaseSpec
    abstract def get_filter(builder : QueryBuilder) : String
  end
end
