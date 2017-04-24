defmodule ElixirService.MailCheckTest do
  use ExUnit.Case, async: true
  alias ElixirService.MailCheck, as: MailCheck
  alias ElixirService.DomainSuggest, as: Suggest

  test "MailCheck writes in the hostanme it checked" do
    answer = MailCheck.check("email@ram9.cc")

    assert Map.get(answer,:hostname) == "ram9.cc"
  end

  test "MailCheck writes a suggestion for gmail" do
    answer = MailCheck.check("email@gnail.com")

    assert Map.get(answer,:suggestion) == "gmail.com"
    assert Map.get(answer,:hasSuggestion) == true
  end

  test "MailCheck writes in validity of hostname" do
    answer = MailCheck.check("email@ram9.cc")

    assert Map.get(answer,:validMx) == true

    answer = MailCheck.check("email@ram9.wrong")

    assert Map.get(answer,:validMx) == false
  end

  test "MailCheck returns correct edit distance" do
    answer = Suggest.edit_distance(String.graphemes("gmail.com"),
                String.graphemes("gmail.com"))
    assert answer == 0

    assert Suggest.edit_distance([], String.graphemes("yahoo.co.in")) == 11
    assert Suggest.edit_distance("yahoo.co.jp", "") == 11
    assert Suggest.edit_distance(String.graphemes("hotmail.com"),
                String.graphemes("hotnail.com")) == 1
    assert Suggest.edit_distance("windows.live.com",
                String.graphemes("window.liev.com")) == 3
    assert Suggest.edit_distance("gnail.com", "gmail.com") == 1
    assert Suggest.edit_distance(String.graphemes("kitten"),
                String.graphemes("sitting")) == 3
    assert Suggest.edit_distance(String.graphemes("saturday"),
                String.graphemes("sunday")) == 3
  end

  test "Filters suggestions on value" do
    answer = Suggest.filter_suggestions(%{"gmail.com" => 2, "yahoo.co" => 1,
      "yahoo.com" => 1, "hotmail.com" => 3}, 1)
    assert answer == %{"yahoo.co" => 1, "yahoo.com" => 1}
  end

  test "Suggests hosts and their edit distances" do
    list = ["gmail.com", "outlook.com", "yahoo.com"]
    host = "gnail.com"
    response = Suggest.suggestions(list, host)
    assert response == %{"gmail.com" => 1, "outlook.com" => 7, "yahoo.com" => 5}
  end

  test "Doesn't give suggestions for unknown domains" do
    response = Suggest.suggest("blarney.cc", ["gmail.com"])
    assert Map.get(response, :hasSuggestion) == false
    assert Map.get(response, :suggestion) == nil
  end
  test "Gives appropriate suggestions" do
    response = Suggest.suggest("gnail.com", ["gmail.com"])
    assert Map.get(response, :hasSuggestion) == true
    assert Map.get(response, :suggestion) == "gmail.com"
  end
end
