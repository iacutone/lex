defmodule LexTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  doctest Lex

  describe "main/1" do
    test "when more than one arg is given as a parameter logs and exits the program" do
      assert capture_log(fn ->
               catch_exit(Lex.main(["foo", "bar"]))
             end) =~ "Usage: lex [script]"
    end

    test "when one argument is given runs the file provided by the parameter" do
    end
  end

  describe "main/0" do
    test "runs the cli prompt" do
    end
  end
end
