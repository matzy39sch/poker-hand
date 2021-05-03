defmodule Poker do
  @moduledoc """
  Documentation for `Poker`.
  A poker deck contains 52 cards - each card has a suit which is one of clubs, diamonds, hearts,
  or spades (denoted C, D, H, and S in the input data).
  Each card also has a value which is one of 2, 3, 4, 5, 6, 7, 8, 9, 10, jack, queen, king, ace (denoted
  2, 3, 4, 5, 6, 7, 8, 9, T, J, Q, K, A).
  For scoring purposes, the suits are unordered while the values are ordered as given above, with
  2 being the lowest and ace the highest value.
  """
  @type card :: {String.t(), String.t()}
  @type hand :: list(card)

  defstruct name: "",
            cards: []

  @doc """
  ## Examples
      iex> Poker.evaluate("Black: 2H 4S 4C 3D 4H", "White: 2S 8S AS QS 3S")
      "White wins - Flush"
      iex> Poker.evaluate("Black: 2H 3D 5S 9C KD", "White: 2D 3H 5C 9S KH")
      "Tie"
      iex> Poker.evaluate("Black: 3H 3D 5S 5C KD", "White: 2D 2H 5C 5S KH")
      "Black wins - Two pair"
      iex> Poker.evaluate("Black: 2H 3D 5S 9C KD", "Black: 2H 3D 5S 9C KD")
      "Tie"
  """
  @spec evaluate(String.t(), String.t()) :: String.t()
  def evaluate(string1, string2) do
    %Poker{name: name1, cards: hand1} = init_hand(string1)
    %Poker{name: name2, cards: hand2} = init_hand(string2)

    case compare(evaluate_hand(hand1), evaluate_hand(hand2)) do
      0 ->
        "Tie"

      {1, rank_name} ->
        "#{name1} wins - #{rank_name}"

      {2, rank_name} ->
        "#{name2} wins - #{rank_name}"
    end
  end

  @doc """
  ## Examples
      iex> Poker.init_hand("Bobby: 2H 4S 2S AH 2D")
      %Poker{
        name: "Bobby",
        cards: [{2, "H"}, {2, "S"}, {2, "D"}, {4, "S"}, {14, "H"}]
        }
  """
  @spec init_hand(String.t()) :: __MODULE__
  def init_hand(input_string) do
    [name | cards] =
      input_string
      |> String.split(" ")

    sorted_cards =
      cards
      |> Enum.map(&{get_number(&1), String.last(&1)})
      |> Enum.sort_by(&elem(&1, 0))

    %__MODULE__{
      name: String.replace(name, ~r/[:]/, ""),
      cards: sorted_cards
    }
  end

  @doc """
  ## Examples
      iex> Poker.get_number("2H")
      2
  """
  @spec get_number(String.t()) :: integer
  def get_number(card) do
    case String.replace(card, ~r/[CSDH]/, "") do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "J" -> 11
      v -> String.to_integer(v)
    end
  end

  @doc """
  ## Examples
      iex> Poker.is_flush([{2, "H"}, {4, "S"}, {2, "S"}, {14, "H"}, {2, "D"}])
      false
      iex> Poker.is_flush([{2, "H"}, {4, "H"}, {7, "H"}, {10, "H"}, {14, "H"}])
      true
  """
  @spec is_flush(hand) :: boolean
  def is_flush(cards) do
    case Enum.map(cards, &elem(&1, 1)) do
      [color, color, color, color, color] -> true
      [_, _, _, _, _] -> false
    end
  end

  @doc """
  ## Examples
      iex> Poker.is_straight([{2, "H"}, {4, "S"}, {2, "S"}, {14, "H"}, {2, "D"}])
      false
      iex> Poker.is_straight([{2, "H"}, {3, "S"}, {4, "S"}, {5, "H"}, {14, "D"}])
      true
      iex> Poker.is_straight([{2, "H"}, {3, "S"}, {4, "S"}, {5, "H"}, {6, "D"}])
      true
  """
  @spec is_straight(hand) :: boolean
  def is_straight([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}])
      when e == d + 1 and e == c + 2 and e == b + 3 and e == a + 4,
      do: true

  def is_straight([{2, _}, {3, _}, {4, _}, {5, _}, {14, _}]), do: true
  def is_straight(_), do: false

  @doc """
  ## Examples
      iex> Poker.high_card([{2, "H"}, {3, "S"}, {4, "S"}, {7, "H"}, {14, "D"}])
      {14, "Ace"}
      iex> Poker.high_card([2, 3, 4, 5, 14])
      {14, "Ace"}
      iex> Poker.high_card([{2, "H"}, {3, "S"}, {4, "S"}, {5, "H"}, {6, "D"}])
      {6, "6"}
  """
  @spec high_card(hand) :: String.t()
  def high_card(hand) do
    case List.last(hand) do
      {14, _} -> {14, "Ace"}
      {13, _} -> {13, "King"}
      {12, _} -> {12, "Queen"}
      {11, _} -> {11, "Jack"}
      {v, _} -> {v, Integer.to_string(v)}
      14 -> {14, "Ace"}
      13 -> {13, "King"}
      12 -> {12, "Queen"}
      11 -> {11, "Jack"}
      v -> {v, Integer.to_string(v)}
    end
  end

  @doc """
  ## Examples
      iex> Poker.evaluate_by_order([{2, "H"}, {3, "S"}, {4, "S"}, {7, "H"}, {14, "D"}])
      %{high_card: {14, "Ace"}, nr: [], rank_name: "High card", rank_value: 0}
      iex> Poker.evaluate_by_order([{2, "H"}, {3, "S"}, {4, "S"}, {5, "H"}, {6, "D"}])
      %{high_card: {6, "6"}, nr: [], rank_name: "High card", rank_value: 0}
      iex> Poker.evaluate_by_order([{2, "S"}, {3, "S"}, {4, "S"}, {5, "S"}, {6, "S"}])
      %{high_card: {6, "6"}, nr: [], rank_name: "High card", rank_value: 0}
  """
  @spec evaluate_by_order(hand) :: String.t()
  def evaluate_by_order(hand) do
    pattern =
      hand
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.map(fn {k, v} -> %{nr: k, len: length(v)} end)
      |> Enum.sort_by(& &1.len)

    case pattern do
      [%{len: 1}, %{len: 1}, %{len: 1}, %{len: 1}, %{len: 1}] ->
        %{rank_value: 0, rank_name: "High card", nr: [], high_card: high_card(hand)}

      [
        %{len: 1, nr: other_nr},
        %{len: 1, nr: other_nr2},
        %{len: 1, nr: other_nr3},
        %{len: 2, nr: nr}
      ] ->
        %{
          rank_value: 1,
          rank_name: "One pair",
          nr: [nr],
          high_card: high_card([other_nr, other_nr2, other_nr3])
        }

      [%{len: 1, nr: other_nr}, %{len: 2, nr: nr}, %{len: 2, nr: nr2}] ->
        %{rank_value: 2, rank_name: "Two pair", nr: [nr, nr2], high_card: other_nr}

      [%{len: 1, nr: other_nr}, %{len: 1, nr: other_nr2}, %{len: 3, nr: nr}] ->
        %{
          rank_value: 3,
          rank_name: "Three of a kind",
          nr: [nr],
          high_card: high_card([other_nr, other_nr2])
        }

      [%{len: 2, nr: nr}, %{len: 3, nr: nr2}] ->
        %{rank_value: 6, rank_name: "Full house", nr: [nr, nr2], high_card: high_card(hand)}

      [%{len: 1, nr: other_nr}, %{len: 4, nr: nr}] ->
        %{rank_value: 7, rank_name: "Four of a kind", nr: [nr], high_card: other_nr}
    end
  end

  @doc """
  ## Examples
      iex> Poker.evaluate_hand([{2, "H"}, {3, "S"}, {4, "S"}, {7, "H"}, {14, "D"}])
      %{high_card: {14, "Ace"}, nr: [], rank_name: "High card", rank_value: 0}
      iex> Poker.evaluate_hand([{2, "H"}, {3, "S"}, {4, "S"}, {5, "H"}, {6, "D"}])
      %{high_card: {6, "6"}, nr: {6, "6"}, rank_name: "Straight", rank_value: 4}
      iex> Poker.evaluate_hand([{2, "S"}, {3, "S"}, {4, "S"}, {5, "S"}, {6, "S"}])
      %{high_card: {6, "6"}, nr: {6, "6"}, rank_name: "Straight flush", rank_value: 8}
  """
  @spec evaluate_hand(hand) :: String.t()
  def evaluate_hand(hand) do
    case {is_straight(hand), is_flush(hand)} do
      {true, true} ->
        %{
          rank_value: 8,
          rank_name: "Straight flush",
          nr: high_card(hand),
          high_card: high_card(hand)
        }

      {true, false} ->
        %{rank_value: 4, rank_name: "Straight", nr: high_card(hand), high_card: high_card(hand)}

      {false, true} ->
        %{rank_value: 5, rank_name: "Flush", nr: high_card(hand), high_card: high_card(hand)}

      _ ->
        evaluate_by_order(hand)
    end
  end

  @doc """
  ## Examples
      iex> Poker.compare(%{high_card: 13, nr: [3, 5], rank_name: "Two pair", rank_value: 2}, %{high_card: 13, nr: [2, 5], rank_name: "Two pair", rank_value: 2} )
      {1, "Two pair"}
      iex> Poker.compare(%{high_card: {13, "King"}, nr: [], rank_name: "High card", rank_value: 0}, %{high_card: {13, "King"}, nr: [], rank_name: "High card", rank_value: 0})
      0
  """
  @spec compare(map(), map()) :: {Integer.t(), String.t()}
  def compare(%{rank_name: rn1, rank_value: rv1}, %{rank_value: rv2})
      when rv1 > rv2 do
    {1, rn1}
  end

  def compare(%{rank_value: rv1}, %{rank_name: rn2, rank_value: rv2})
      when rv1 < rv2 do
    {2, rn2}
  end

  def compare(%{rank_value: rv1, high_card: {hc1, hcn1}}, %{rank_value: rv2, high_card: {hc2, _}})
      when rv1 == rv2 and hc1 > hc2 do
    {1, "High card: #{hcn1}"}
  end

  def compare(%{rank_value: rv1, high_card: {hc1, _}}, %{rank_value: rv2, high_card: {hc2, hcn2}})
      when rv1 == rv2 and hc1 < hc2 do
    {2, "High card: #{hcn2}"}
  end

  def compare(%{rank_name: rn1, rank_value: rv1, nr: nr1}, %{rank_value: rv2, nr: nr2})
      when rv1 == rv2 and nr1 > nr2 do
    {1, rn1}
  end

  def compare(%{rank_value: rv1, nr: nr1}, %{rank_name: rn2, rank_value: rv2, nr: nr2})
      when rv1 == rv2 and nr1 < nr2 do
    {2, rn2}
  end

  def compare(%{rank_value: rv1, high_card: hc1, nr: nr1}, %{
        rank_value: rv2,
        high_card: hc2,
        nr: nr2
      })
      when rv1 == rv2 and hc1 == hc2 and nr1 == nr2 do
    0
  end
end
