defmodule Parser do
  @moduledoc "my attempt at writing a Pratt parser"
  require Logger

  @precedence %{
    Token.plus() => 4,
    Token.minus() => 4,
    Token.star() => 5,
    Token.slash() => 5
  }

  def run(tokens) do
    parse_expression(tokens, 0, "") |> String.replace("\"", "") |> String.trim()
  end

  @doc "Defined as 'led' or left denotation in the original paper"
  @spec parse_expression(list(Token.t()), non_neg_integer(), String.t()) :: String.t()
  def parse_expression([%Token{type: nil} = token], _precedence, s_expression) do
    Logger.error("Could not parse", token: token)
    s_expression
  end

  def parse_expression(tokens, precedence, s_expression) do
    # take the first 'nud' or null denotation token and assign 0 precedence
    {%{literal: literal}, token_tail} = next(tokens)

    next_precedence = get_precedence(peek(tokens).type)

    if precedence < next_precedence do
      {%{lexeme: op}, token_tail} = next(token_tail)

      s_expression = s_expression <> " " <> "(#{op} " <> "#{literal}"

      parse_expression(token_tail, next_precedence, s_expression)
    else
      Macro.to_string(quote do: unquote(s_expression <> " " <> literal <> ")")) <> ")"
    end
  end

  defp get_precedence(type) do
    Map.get(@precedence, type, 1)
  end

  defp next(tokens) do
    {List.first(tokens), List.delete_at(tokens, 0)}
  end

  defp peek(tokens) do
    Enum.at(tokens, 1)
  end
end
