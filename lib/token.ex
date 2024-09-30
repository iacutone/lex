defmodule Token do
  defstruct [:type, :lexeme, :literal, :line]

  #   // Keywords.
  #   AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,
  #   PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,

  #   EOF
  # }

  # Single-character tokens
  @left_paren :left_paren
  @right_paren :right_paren
  @left_brace :left_brace
  @right_brace :right_brace
  @comma :comma
  @dot :dot
  @minus :minus
  @plus :plus
  @semicolon :semicolon
  @slash :slash
  @star :star

  # One or two character tokens.
  @bang :bang
  @bang_equal :bang_equal
  @equal :equal
  @equal_equal :equal_equal
  @less_than :less_than
  @less_than_equal :less_than_equal
  @greater_than :greater_than
  @greater_than_equal :greater_than_equal

  # Literals.
  @identifier :identifier
  @string :string
  @number :number

  # Keywords.
  @keywords %{
    "and" => :and,
    "class" => :class,
    "else" => :else,
    "false" => false,
    "fun" => :fun,
    "for" => :for,
    "if" => :if,
    "nil" => nil,
    "or" => :or,
    "print" => :print,
    "return" => :return,
    "this" => :this,
    "true" => true,
    "var" => :var,
    "while" => :while
  }

  @eof :eof

  @type literal :: String.t() | integer() | float() | nil
  @type t ::
          %__MODULE__{type: atom(), lexeme: String.t(), literal: literal(), line: pos_integer()}

  @spec build(%{type: atom(), lexeme: String.t(), literal: literal(), line: pos_integer()}) ::
          Token.t()
  def build(%{type: type, lexeme: lexeme, literal: literal, line: line}) do
    %Token{
      type: type,
      lexeme: lexeme,
      literal: literal,
      line: line
    }
  end

  def add_token("(" = text, line) do
    %Token{type: @left_paren, lexeme: text, literal: nil, line: line}
  end

  def add_token(")" = text, line) do
    %Token{type: @right_paren, lexeme: text, literal: nil, line: line}
  end

  def add_token("{" = text, line) do
    %Token{type: @left_brace, lexeme: text, literal: nil, line: line}
  end

  def add_token("}" = text, line) do
    %Token{type: @right_brace, lexeme: text, literal: nil, line: line}
  end

  def add_token("," = text, line) do
    %Token{type: @comma, lexeme: text, literal: nil, line: line}
  end

  def add_token("." = text, line) do
    %Token{type: @dot, lexeme: text, literal: nil, line: line}
  end

  def add_token("-" = text, line) do
    %Token{type: @minus, lexeme: text, literal: nil, line: line}
  end

  def add_token("+" = text, line) do
    %Token{type: @plus, lexeme: text, literal: nil, line: line}
  end

  def add_token(";" = text, line) do
    %Token{type: @semicolon, lexeme: text, literal: nil, line: line}
  end

  def add_token("/" = text, line) do
    %Token{type: @slash, lexeme: text, literal: nil, line: line}
  end

  def add_token("*" = text, line) do
    %Token{type: @star, lexeme: text, literal: nil, line: line}
  end

  def add_token("!" = text, line) do
    %Token{type: @bang, lexeme: text, literal: nil, line: line}
  end

  def add_token("!=" = text, line) do
    %Token{type: @bang_equal, lexeme: text, literal: nil, line: line}
  end

  def add_token("=" = text, line) do
    %Token{type: @equal, lexeme: text, literal: nil, line: line}
  end

  def add_token("==" = text, line) do
    %Token{type: @equal_equal, lexeme: text, literal: nil, line: line}
  end

  def add_token("<" = text, line) do
    %Token{type: @less_than, lexeme: text, literal: nil, line: line}
  end

  def add_token("<=" = text, line) do
    %Token{type: @less_than_equal, lexeme: text, literal: nil, line: line}
  end

  def add_token(">" = text, line) do
    %Token{type: @greater_than, lexeme: text, literal: nil, line: line}
  end

  def add_token(">=" = text, line) do
    %Token{type: @greater_than_equal, lexeme: text, literal: nil, line: line}
  end

  def eof, do: @eof

  def string, do: @string

  def number, do: @number

  def keywords, do: @keywords

  def keyword(word), do: Map.get(keywords(), word)

  # def to_string(token) do
  #   to_string("#{token.type}" <> "#{token.lexeme}" <> "#{token.literal}")
  # end
end
