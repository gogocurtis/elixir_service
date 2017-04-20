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
end
