defmodule ElixirService.MailCheckTest do
  use ExUnit.Case, async: true
  alias ElixirService.MailCheck, as: MailCheck
  alias ElixirService.DomainSuggest, as: Suggest

  test "MailCheck writes in the hostanme it checked" do
    answer = MailCheck.check("email@ram9.cc")

    assert Map.get(answer,:hostname) == "ram9.cc"
  end

  test "MailCheck writes in validity of hostname" do
    answer = MailCheck.check("email@ram9.cc")

    assert Map.get(answer,:valid_mx) == true

    answer = MailCheck.check("email@ram9.wrong")

    assert Map.get(answer,:valid_mx) == false
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

  test "Gives appropriate suggestions" do
    check =  MailCheck.check("email@gnail.com")
    response = Suggest.suggestion_for(check, "gnail.com", ["gmail.com", "yahoo.com"])
    assert Map.get(response, :has_suggestion) == true
    assert Map.get(response, :suggestion) == %{"gmail.com" => 1}
  end
end
