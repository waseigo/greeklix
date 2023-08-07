defmodule Greeklix do
  @moduledoc """
  Documentation for `Greeklix`.
  """

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
    "ω" => ["w", "o", "v"],
    ";" => ["?"],
  }

  @rules Greeklix.compile_substitution_rules()

  @doc """
  Hello world.

  ## Examples

      iex> Greeklix.hello()
      :world

  """
  def hello do
    IO.inspect(@rules)
  end

  def generate_digraph_cases(digraph) when is_bitstring(digraph) do
    [&String.downcase/2, &String.capitalize/2, &String.upcase/2]
      |> Enum.map(fn x -> x.(digraph, :greek) end)
  end

  def compile_substitution_rules() do
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

    greek_abc =
      "α"
      |> String.to_charlist()
      |> hd()
      |> (fn x -> Range.new(x, x + 24) end).()
      |> Enum.to_list()
      |> List.to_string()
      |> String.graphemes()

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

    expanded_rules =
      [digraph_rules, monograph_rules]
      |> Enum.map(fn ruleset ->
        ruleset |> Enum.map(fn rule -> Greeklix.expand_case(rule) end)
      end)
      |> List.flatten() |> Map.new()

    expanded_rules
    |> Map.merge(digraph_rules)
    |> Map.merge(monograph_rules)
    |> Map.merge(@othersubs)

  end

  def expand_case(kvpair) do
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

  def remove_accent_chars(input_tokens) when is_list(input_tokens) do
    input_tokens
    |> Enum.map(fn x -> String.normalize(x, :nfd) |> String.codepoints() |> hd() end)
  end

  def detect_digraphs(input_tokens, acc \\ [])

  def detect_digraphs(input_tokens, acc) when length(input_tokens) > 1 do
    [a, b | tail] = input_tokens

    case String.downcase(a <> b) in Map.keys(@digraphs) do
      true -> detect_digraphs(tail, acc ++ [a <> b])
      false -> detect_digraphs([b] ++ tail, acc ++ [a])
    end
  end

  def detect_digraphs(input_tokens, acc) when length(input_tokens) == 1 or input_tokens == [] do
    acc ++ input_tokens
  end


  def substitute(input_tokens, variant \\ 0) do
    input_tokens
      |> Enum.map(
        fn x ->
          if x in Map.keys(@rules) do
           @rules[x] |> Enum.at(min(variant, length(@rules[x])-1))
          else
            x
          end
        end
      )
  end

end
