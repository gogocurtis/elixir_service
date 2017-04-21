defmodule ElixirService.MailCheckTest do
  use ExUnit.Case, async: true

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
    answer = MailCheck.edit_distance(String.graphemes("gmail.com"), 
                String.graphemes("gmail.com"))
    assert answer == 0
    
    assert MailCheck.edit_distance([], String.graphemes("yahoo.co.in")) == 11
    assert MailCheck.edit_distance(String.graphemes("yahoo.co.jp"), []) == 11
    assert MailCheck.edit_distance(String.graphemes("hotmail.com"), 
                String.graphemes("hotnail.com")) == 1
    assert MailCheck.edit_distance(String.graphemes("windows.live.com"), 
                String.graphemes("window.liev.com")) == 3
    assert MailCheck.edit_distance(String.graphemes("gnail.com"), 
                String.graphemes("gmail.com")) == 1
    assert MailCheck.edit_distance(String.graphemes("kitten"), 
                String.graphemes("sitting")) == 3
    assert MailCheck.edit_distance(String.graphemes("saturday"), 
                String.graphemes("sunday")) == 3
  end
end
