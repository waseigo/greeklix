defmodule Greeklix.Rules do
  @moduledoc """
  Module containing functions for generating substitution rules at compile time.
  """

  @moduledoc since: "0.1.0"

  @digraphs %{
    "αι" => "e",
    "ει" => "i",
    "οι" => "i",
    "ου" => "ou",
    "ευ" => "eu",
    "αυ" => "au",
    "μπ" => "b",
    "γγ" => "g",
    "γκ" => "g",
    "ντ" => "d"
  }

  @othersubs %{
    "β" => ["b", "v"],
    "η" => ["h", "i"],
    "θ" => ["th", "8"],
    "ξ" => ["x", "ks"],
    "υ" => ["y", "u", "i"],
    "φ" => ["f", "ph"],
    "χ" => ["x", "h", "ch"],
    "ω" => ["w", "o", "v"]
  }

  # Generate downcase, capitalized, and upcase variants of a digraph.
  defp generate_digraph_cases(digraph) when is_bitstring(digraph) do
    [&String.downcase/2, &String.capitalize/2, &String.upcase/2]
    |> Enum.map(fn x -> x.(digraph, :greek) end)
  end

  @doc """
  Compile substitution rules and make them available to all functions through the `@rules` module attribute of the `Greeklix` module. Only used during compilation.
  """
  @doc since: "0.1.0"
  def compile_substitution_rules() do
    # generate basic substitution using the Unidecode module
    rules_digraphs =
      Map.keys(@digraphs)
      |> Map.new(fn x -> {x, [Unidecode.decode(x)]} end)

    # fix basic digraphs
    rules =
      for {k, v} <- rules_digraphs do
        if k in Map.keys(@digraphs) and hd(v) != @digraphs[k] do
          {k, v ++ [@digraphs[k]]}
        else
          {k, v}
        end
      end
      |> Map.new()

    # generate special substitutions for three digraphs with ypsilon (υ)
    digraph_rules =
      for {k, v} <- rules do
        cond do
          k == "ου" ->
            {k, v ++ ["oy", "u"]}

          k in ["αυ", "ευ"] ->
            initial =
              k
              |> String.graphemes()
              |> hd()
              |> Unidecode.decode()

            variants =
              "fvy"
              |> String.graphemes()
              |> Enum.map(&Kernel.<>(initial, &1))

            {k, v ++ variants}

          true ->
            {k, v}
        end
      end
      |> Map.new()

    # generate the Greek alphabet
    greek_abc =
      "α"
      |> String.to_charlist()
      |> hd()
      |> (fn x -> Range.new(x, x + 24) end).()
      |> Enum.to_list()
      |> List.to_string()
      |> String.graphemes()

    # generate rules for single-letter substitutions, taking into account the special cases in @othersubs
    monograph_rules =
      greek_abc
      |> Enum.map(fn x ->
        if x not in Map.keys(@othersubs) do
          {x, [Unidecode.decode(x)]}
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Map.new()
      |> Map.merge(@othersubs)

    # expand every rule to cover downcase, capitalized, and upcase variations
    expanded_rules =
      [digraph_rules, monograph_rules]
      |> Enum.map(fn ruleset ->
        ruleset |> Enum.map(fn rule -> expand_rule(rule) end)
      end)
      |> List.flatten()
      |> Map.new()

    # merge all rules into one
    expanded_rules
    |> Map.merge(digraph_rules)
    |> Map.merge(monograph_rules)
    |> Map.merge(@othersubs)
  end

  # Expand a rule to capitalized (and possibly also upcase) variations.
  defp expand_rule(kvpair) do
    {k, v} = kvpair

    if String.length(k) > 1 do
      [&String.capitalize/1, &String.upcase/1]
    else
      [&String.capitalize/1]
    end
    |> Enum.map(fn x ->
      {
        x.(k),
        Enum.map(v, fn y -> x.(y) end)
      }
    end)
  end
end
