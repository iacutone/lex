defmodule Lex do
  @moduledoc """
  Documentation for `Lex`.
  """

  require Logger

  @doc """
  """
  def main(path) when length(path) > 1 do
    Logger.error("Usage: lex [script]")
    exit({:shutdown, 64})
  end

  def main(path) when is_binary(path) do
    run_file(path)
  end

  def main do
    run_prompt()
  end

  defp run_file(file) do
    {:ok, file} = File.read(file)
    Lexer.run(file)
  end

  defp run_prompt do
    # TODO
  end
end
