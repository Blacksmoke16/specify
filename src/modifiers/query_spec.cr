module Specify(T)
  # Base struct for custom specs.
  abstract struct QuerySpec
    abstract def get_spec : BaseSpec
  end
end
