defmodule KeyDiffTest do
  use ExUnit.Case
  doctest KeyDiff

  describe "map" do
    test "no changes" do
      assert KeyDiff.diff(
               %{"a" => "a"},
               %{"a" => "a"}
             ) == {[], [], []}
    end

    test "key changes" do
      assert KeyDiff.diff(
               %{"a" => "a"},
               %{"a" => "b"}
             ) == {[], [], ["a"]}
    end

    test "add key" do
      assert KeyDiff.diff(
               %{"a" => "a"},
               %{"a" => "a", "b" => "b"}
             ) == {["b"], [], []}
    end

    test "delete key" do
      assert KeyDiff.diff(
               %{"a" => "a", "b" => "b"},
               %{"a" => "a"}
             ) == {[], ["b"], []}
    end

    test "delete and add key" do
      assert KeyDiff.diff(
               %{"a" => "a"},
               %{"b" => "a"}
             ) == {["b"], ["a"], []}
    end

    test "nested additions and changes" do
      assert KeyDiff.diff(
               %{"a" => %{"1" => 1, "2" => 2, "x" => %{"x1" => 1, "x2" => 2}}, "b" => "b"},
               %{
                 "a" => %{"1" => 1, "2" => 3, "3" => 3, "x" => %{"x1" => 1, "x2" => 2, "x3" => 5}},
                 "c" => "c"
               }
             ) == {[["a", [["x", ["x3"]], "3"]], "c"], ["b"], [["a", ["2"]]]}
    end

    test "nested changes" do
      assert KeyDiff.diff(
               %{
                 "a" => %{
                   "1" => 1,
                   "2" => 2,
                   "x" => %{
                     "x1" => 1,
                     "x2" => 2
                   }
                 },
                 "b" => "b"
               },
               %{
                 "a" => %{
                   "1" => 1,
                   # changed
                   "2" => 3,
                   # added
                   "3" => 3,
                   "x" => %{
                     "x1" => 1,
                     # changed
                     "x2" => 5
                   }
                 },
                 # changed
                 "b" => "b2",
                 # added
                 "c" => "c"
               }
             ) == {[["a", ["3"]], "c"], [], [["a", [["x", ["x2"]], "2"]]]}
    end
  end
end
