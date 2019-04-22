require "./spec_helper"

describe Specify do
  describe Specify::LogicOperator do
    describe ".and" do
      describe "with one filter" do
        it "should generate correctly" do
          assert_filter("s.age > ?;", [30]) do
            Specify.and(Specify(Int32).gt("age", 30))
          end
        end
      end

      describe "with two filter filters" do
        it "should generate correctly" do
          assert_filter("(g.age >= ? AND s.name LIKE ?);", [30, "\"Jim\""]) do
            Specify.and(
              Specify(Int32).gte("age", 30, "g"),
              Specify(String).like("name", "Jim")
            )
          end
        end
      end
    end

    describe ".or" do
      describe "with one filter" do
        it "should generate correctly" do
          assert_filter("s.age <> ?;", [30]) do
            Specify.or(Specify(Int32).neq("age", 30))
          end
        end
      end

      describe "with two filter filters" do
        it "should generate correctly" do
          assert_filter("(s.age <= ? OR s.name NOT LIKE ?);", [30, "\"Jim\""]) do
            Specify.or(
              Specify(Int32).lte("age", 30),
              Specify(String).not_like("name", "Jim")
            )
          end
        end
      end
    end

    describe "#add" do
      describe "it can add another filter into an existing logic operator" do
        it "should be included in the where clause" do
          assert_filter("(s.age < ? AND foo.id NOT IN ?);", [2, "(1,2,3)"]) do
            spec = Specify.and(
              Specify(Int32).lt("age", 2)
            )
            spec.add Specify(Array(Int32)).not_in("id", [1, 2, 3], "foo")

            spec
          end
        end
      end
    end

    describe "with mixed operators" do
      it "should generate correctly" do
        assert_filter("(s.age < ? OR (s.name IN ? AND s.id = ?));", [3.1459, "(\"Jim\",\"Bob\")", 1]) do
          Specify.or(
            Specify(Float64).lt("age", 3.1459),
            Specify.and(
              Specify(Array(String)).in("name", ["Jim", "Bob"]),
              Specify(Bool).eq("id", true)
            )
          )
        end
      end
    end
  end
end
