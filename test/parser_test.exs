defmodule ParserTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  describe "run/1" do
    test "when the token does not contain a type logs an error" do
      assert capture_log(fn ->
               Parser.run([%Token{}])
             end) =~ "Could not parse"
    end

    test "when the token list is correct returns a S-expression" do
      assert "(+ 1 (* 2 3))" ==
               Parser.run([
                 %Token{lexeme: "\"", line: 1, literal: "1", type: :number},
                 %Token{lexeme: "+", line: 1, literal: nil, type: :plus},
                 %Token{lexeme: "\"", line: 1, literal: "2", type: :number},
                 %Token{lexeme: "*", line: 1, literal: nil, type: :star},
                 %Token{lexeme: "\"", line: 1, literal: "3", type: :number},
                 %Token{lexeme: "", line: 1, literal: nil, type: :eof}
               ])
    end
  end
end
