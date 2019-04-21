class String
  def to_sql
    String.build do |str|
      str << self
    end
  end
end

struct Number
  def to_sql
    self
  end
end

struct Nil
  def to_sql
    String.build do |str|
      str << 'N'
      str << 'U'
      str << 'L'
      str << 'L'
    end
  end
end

struct Bool
  def to_sql
    self ? 1 : 0
  end
end

class Array(T)
  def to_sql : String
    String.build do |str|
      str << '('
      str << self.map(&.to_sql).join(',')
      str << ')'
    end
  end
end
