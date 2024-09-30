defmodule LexerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  describe "run/1" do
    test "appends the eof token" do
      assert %Token{type: :eof, line: 1} = Lexer.run("") |> List.last()
    end

    test "tokenizes strings correctly" do
      assert [%Token{lexeme: "\"", line: 1, literal: "hello", type: :string}, %Token{type: :eof}] =
               Lexer.run("\"hello\"")
    end

    test "logs an error for unclosed strings" do
      assert capture_log(fn -> Lexer.run("\"") end) =~ "Unterminated string."
    end

    test "tokenizes one and two characters chars correctly" do
      s = ~S"""
      // this is a comment
      (( )){} // grouping stuff
      !*+-/=<> <= == // operators
      """

      assert [
               %Token{lexeme: "(", line: 2, literal: nil, type: :left_paren},
               %Token{lexeme: "(", line: 2, literal: nil, type: :left_paren},
               %Token{lexeme: ")", line: 2, literal: nil, type: :right_paren},
               %Token{lexeme: ")", line: 2, literal: nil, type: :right_paren},
               %Token{lexeme: "{", line: 2, literal: nil, type: :left_brace},
               %Token{lexeme: "}", line: 2, literal: nil, type: :right_brace},
               %Token{lexeme: "!", line: 3, literal: nil, type: :bang},
               %Token{lexeme: "*", line: 3, literal: nil, type: :star},
               %Token{lexeme: "+", line: 3, literal: nil, type: :plus},
               %Token{lexeme: "-", line: 3, literal: nil, type: :minus},
               %Token{lexeme: "/", line: 3, literal: nil, type: :slash},
               %Token{lexeme: "=", line: 3, literal: nil, type: :equal},
               %Token{lexeme: "<", line: 3, literal: nil, type: :less_than},
               %Token{lexeme: ">", line: 3, literal: nil, type: :greater_than},
               %Token{lexeme: "<=", line: 3, literal: nil, type: :less_than_equal},
               %Token{lexeme: "==", line: 3, literal: nil, type: :equal_equal},
               %Token{lexeme: "", line: 4, literal: nil, type: :eof}
             ] = Lexer.run(s)
    end

    test "tokenizes numbers correctly" do
      assert [%Token{lexeme: "\"", line: 1, literal: "1234", type: :string}, _] =
               Lexer.run("\"1234\"")
    end

    test "tokenizes floats correctly" do
      assert [%Token{lexeme: "\"", line: 1, literal: "12.34", type: :string}, _] =
               Lexer.run("\"12.34\"")
    end

    test "tokenizes keywords correctly" do
      assert [%Token{lexeme: nil, line: 1, literal: nil, type: :fun}, _] = Lexer.run("fun")
      assert [%Token{lexeme: nil, line: 1, literal: nil, type: :if}, _] = Lexer.run("if")
      assert [%Token{lexeme: nil, line: 1, literal: nil, type: :while}, _] = Lexer.run("while")
    end
  end
end
