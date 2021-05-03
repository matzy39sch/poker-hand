defmodule PokerTest do
  use ExUnit.Case
  doctest Poker

  test "get_number" do
    card = "4S"
    assert Poker.get_number(card) == 4
  end
end
