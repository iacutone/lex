defmodule Lexer do
  require Logger

  def run(source) do
    source
    |> String.at(0)
    |> tokenize(%{
      lexed: [],
      source: source,
      source_length: String.length(source),
      stats: %{current: 0, line: 1}
    })
    |> Enum.reverse()
  end

  defp tokenize(nil, %{lexed: acc, stats: stats}) do
    %{line: line} = stats

    [Token.build(%{type: Token.eof(), lexeme: "", literal: nil, line: line}) | acc]
  end

  defp tokenize(token, %{
         lexed: acc,
         source: source,
         source_length: source_length,
         stats: stats
       }) do
    %{current: current, line: line} = stats

    {lexed, stats} =
      case token do
        "\n" ->
          {acc, Map.merge(stats, %{line: line + 1, current: current + 1})}

        "!" ->
          if match?(stats, source_length, "=", source) do
            {[Token.add_token("!=", line) | acc], Map.put(stats, :current, current + 2)}
          else
            {[Token.add_token("!", line) | acc], Map.put(stats, :current, current + 1)}
          end

        "=" ->
          if match?(stats, source_length, "=", source) do
            {[Token.add_token("==", line) | acc], Map.put(stats, :current, current + 2)}
          else
            {[Token.add_token("=", line) | acc], Map.put(stats, :current, current + 1)}
          end

        "<" ->
          if match?(stats, source_length, "=", source) do
            {[Token.add_token("<=", line) | acc], Map.put(stats, :current, current + 2)}
          else
            {[Token.add_token("<", line) | acc], Map.put(stats, :current, current + 1)}
          end

        ">" ->
          if match?(stats, source_length, "=", source) do
            {[Token.add_token(">=", line) | acc], Map.put(stats, :current, current + 1)}
          else
            {[Token.add_token(">", line) | acc], Map.put(stats, :current, current + 1)}
          end

        "/" ->
          if match?(stats, source_length, "/", source) do
            %{current: current} = stats = ignore_comment(stats, source, source_length)
            {acc, Map.put(stats, :current, current + 1)}
          else
            {[Token.add_token("/", line) | acc], Map.put(stats, :current, current + 1)}
          end

        " " ->
          {acc, Map.put(stats, :current, current + 1)}

        "\r" ->
          {acc, Map.put(stats, :current, current + 1)}

        "\t" ->
          {acc, Map.put(stats, :current, current + 1)}

        t ->
          stats = Map.put(stats, :current, current + 1)

          case t do
            "(" ->
              {[Token.add_token("(", line) | acc], stats}

            ")" ->
              {[Token.add_token(")", line) | acc], stats}

            "{" ->
              {[Token.add_token("{", line) | acc], stats}

            "}" ->
              {[Token.add_token("}", line) | acc], stats}

            "," ->
              {[Token.add_token(",", line) | acc], stats}

            "." ->
              {[Token.add_token(".", line) | acc], stats}

            "-" ->
              {[Token.add_token("-", line) | acc], stats}

            "+" ->
              {[Token.add_token("+", line) | acc], stats}

            ";" ->
              {[Token.add_token(";", line) | acc], stats}

            "*" ->
              {[Token.add_token("*", line) | acc], stats}

            "\"" ->
              start = Map.get(stats, :current)
              %{current: current} = stats = consume_string(source, source_length, stats)

              {[
                 Token.build(%{
                   type: Token.string(),
                   lexeme: "\"",
                   literal: String.slice(source, start, current - 1),
                   line: Map.get(stats, :line)
                 })
               ], Map.put(stats, :current, current + 1)}

            char ->
              {acc, stats} =
                cond do
                  is_alpha?(char) ->
                    start = Map.get(stats, :current)
                    %{current: current} = stats = consume_identifier(source, source_length, stats)
                    identifier = String.slice(source, start - 1, current + 1)
                    keyword = Token.keyword(identifier)

                    {[
                       Token.build(%{
                         type: keyword,
                         lexeme: nil,
                         literal: nil,
                         line: Map.get(stats, :line)
                       })
                     ], Map.put(stats, :current, current + 1)}

                  is_digit?(char) ->
                    start = Map.get(stats, :current)

                    %{current: current} = stats = consume_number(source, source_length, stats)

                    {[
                       Token.build(%{
                         type: Token.number(),
                         lexeme: nil,
                         literal: String.slice(source, start, current - 1),
                         line: Map.get(stats, :line)
                       })
                     ], Map.put(stats, :current, current)}

                  true ->
                    Logger.error("Unexpected character #{char}",
                      line: Map.get(stats, :line)
                    )
                end

              {acc, stats}
          end
      end

    tokenize(String.at(source, Map.get(stats, :current)), %{
      lexed: lexed,
      source: source,
      source_length: source_length,
      stats: stats
    })
  end

  defp is_at_end?(current, source_length) do
    current >= source_length
  end

  defp is_digit?(c) when is_binary(c) do
    c = String.to_integer(c)
    c >= 0 && c <= 9
  end

  defp is_digit?(_c), do: false

  defp is_alpha?(<<c>>) when c in ?a..?z, do: true

  defp is_alpha?(<<c>>) when c in ?A..?Z, do: true

  defp is_alpha?("_"), do: true

  defp is_alpha?(_), do: false

  defp is_alpha_numeric?(c), do: is_alpha?(c) || is_digit?(c)

  defp ignore_comment(stats, source, source_length) do
    current = Map.get(stats, :current)

    %{current: current} =
      if peek(stats, source_length, source) != "\n" &&
           !is_at_end?(current, source_length) do
        stats = Map.put(stats, :current, current + 1)
        ignore_comment(stats, source, source_length)
      else
        stats
      end

    Map.put(stats, :current, current)
  end

  defp match?(stats, source_length, expected, source) do
    current = Map.get(stats, :current)

    cond do
      is_at_end?(current + 1, source_length) ->
        false

      expected != String.at(source, current + 1) ->
        false

      true ->
        true
    end
  end

  defp peek(stats, source_length, source) do
    current = Map.get(stats, :current) + 1

    if is_at_end?(current, source_length) do
      '\0'
    else
      String.at(source, current)
    end
  end

  def peek_next(stats, source_length, source) do
    current = Map.get(stats, :current) + 2

    if is_at_end?(current, source_length) do
      '\0'
    else
      String.at(source, current)
    end
  end

  defp consume_string(source, source_length, stats) do
    current = Map.get(stats, :current)

    %{current: current, line: line} =
      if peek(stats, source_length, source) != "\"" &&
           !is_at_end?(current, source_length) do
        stats =
          if peek(stats, source_length, source) == "\n" do
            Map.put(stats, :line, Map.get(stats, :line) + 1)
          else
            stats
          end

        stats = Map.put(stats, :current, current + 1)
        consume_string(source, source_length, stats)
      else
        if peek(stats, source_length, source) != "\"" && is_at_end?(current, source_length) do
          Logger.error("Unterminated string.", line: Map.get(stats, :line))
        end

        Map.put(stats, :current, current + 1)
      end

    stats
    |> Map.put(:current, current)
    |> Map.put(:line, line)
  end

  defp consume_number(source, source_length, stats) do
    current = Map.get(stats, :current)

    %{current: current} =
      stats =
      if is_digit?(peek(stats, source_length, source)) do
        stats = Map.put(stats, :current, current + 1)

        if peek(stats, source_length, source) ==
             "." && is_digit?(peek_next(stats, source_length, source)) do
          stats = Map.put(stats, :current, current + 1)
          consume_number(source, source_length, stats)
        end

        consume_number(source, source_length, stats)
      else
        stats
      end

    Map.put(stats, :current, current)
  end

  defp consume_identifier(source, source_length, stats) do
    current = Map.get(stats, :current)

    %{current: current} =
      if is_alpha_numeric?(peek(stats, source_length, source)) do
        stats = Map.put(stats, :current, current + 1)
        consume_identifier(source, source_length, stats)
      else
        stats
      end

    Map.put(stats, :current, current)
  end
end
