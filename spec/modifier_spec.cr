require "./spec_helper"

describe Specify do
  describe Specify::Select do
    describe "with an array of names" do
      it "should alter the select portion of the query" do
        assert_filter("", [] of DB::Any, "SELECT foo, bar FROM contacts s;") do
          Specify.and(Specify.select(["foo", "bar"]))
        end
      end
    end

    describe "with an array and aliases" do
      it "should alter the select portion of the query" do
        assert_filter("", [] of DB::Any, "SELECT s.foo, j.bar FROM contacts s;") do
          Specify.and(Specify.select(["s.foo", "j.bar"]))
        end
      end
    end
  end

  describe Specify::Join do
    describe "with a single join" do
      it "should add a join to the query" do
        assert_filter("", [] of DB::Any, "SELECT * FROM contacts s JOIN users u ON u.id = s.user_id;") do
          Specify.and(Specify(User).join("u", Specify.on("u.id", "s.user_id")))
        end
      end
    end

    describe "with a single join and a comparison" do
      it "should add a join to the query" do
        assert_filter("u.is_admin = ?;", [1], "SELECT * FROM contacts s JOIN users u ON u.id = s.user_id") do
          Specify.and(
            Specify(Bool).eq("is_admin", true, "u"),
            Specify(User).join("u", Specify.on("u.id", "s.user_id"))
          )
        end
      end
    end

    describe "with multiple joins" do
      it "should add a join to the query" do
        assert_filter("", [] of DB::Any, "SELECT * FROM contacts s JOIN users u ON u.id = s.user_id JOIN contacts c ON u.id = c.user_id JOIN posts p ON c.id = p.post_id;") do
          Specify.and(
            Specify(User).join("u", Specify.on("u.id", "s.user_id")),
            Specify(Contact).join("c", Specify.on("u.id", "c.user_id")),
            Specify(Post).join("p", Specify.on("c.id", "p.post_id")),
          )
        end
      end
    end

    describe "with multiple joins and comparisions" do
      it "should add a join to the query" do
        assert_filter("(u.id = ? AND p.published = ?);", [99, 1], "SELECT * FROM contacts s JOIN users u ON u.id = s.user_id JOIN contacts c ON u.id = c.user_id JOIN posts p ON c.id = p.post_id") do
          Specify.and(
            Specify(Int32).eq("id", 99, "u"),
            Specify(User).join("u", Specify.on("u.id", "s.user_id")),
            Specify(Contact).join("c", Specify.on("u.id", "c.user_id")),
            Specify(Bool).eq("published", true, "p"),
            Specify(Post).join("p", Specify.on("c.id", "p.post_id")),
          )
        end
      end
    end
  end
end
