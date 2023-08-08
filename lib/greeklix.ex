defmodule Greeklix do
  require Greeklix.Rules

  @moduledoc """
  Module containing functions for converting Greek text to Greeklish.
  """

  @moduledoc since: "0.1.0"

  @rules Greeklix.Rules.compile_substitution_rules()

  @doc """
  Show the compiled substitution rules.
  """
  @doc since: "0.1.0"
  def get_rules do
    @rules
  end

  # Remove accent characters from text.
  defp remove_accent_chars(input_tokens) when is_list(input_tokens) do
    input_tokens
    |> Enum.map(fn x ->
      String.normalize(x, :nfd) |> String.codepoints() |> hd()
    end)
  end

  # Detect digraphs that will be substituted based on the `@rules` module attribute.
  defp detect_digraphs(input_tokens, acc \\ [])

  defp detect_digraphs(input_tokens, acc) when length(input_tokens) > 1 do
    [a, b | tail] = input_tokens

    case String.downcase(a <> b) in Map.keys(@rules) do
      true -> detect_digraphs(tail, acc ++ [a <> b])
      false -> detect_digraphs([b] ++ tail, acc ++ [a])
    end
  end

  defp detect_digraphs(input_tokens, acc)
       when length(input_tokens) == 1 or input_tokens == [] do
    acc ++ input_tokens
  end

  # Perform substitutions based on the compiled rules, with an optional parameter of the variant number (integer)
  defp substitute(input_tokens, variant \\ 0) do
    input_tokens
    |> Enum.map(fn x ->
      if x in Map.keys(@rules) do
        @rules[x] |> Enum.at(min(variant, length(@rules[x]) - 1))
      else
        x
      end
    end)
  end

  @doc """
  Convert Greek text to Greeklish, with an optional parameter of the variant number (integer).
  """
  @doc since: "0.1.0"
  def convert(input_tokens, variant \\ 0) do
    input_tokens
    |> String.graphemes()
    |> remove_accent_chars()
    |> detect_digraphs()
    |> substitute(variant)
    |> List.to_string()
  end
end
