defmodule PokerTest do
  use ExUnit.Case
  doctest Poker

  test "get_number" do
    card = "4S"
    assert Poker.get_number(card) == 4
  end
  
  test "White wins - high card: Ace" do
    assert Poker.evaluate("Black: 2H 3D 5S 9C KD","White: 2C 3H 4S 8C AH") == "White wins - high card: Ace"
  end

  test "White wins - Flush" do
    assert Poker.evaluate("Black: 2H 4S 4C 3D 4H","White: 2S 8S AS QS 3S") == "White wins - Flush"
  end
end
