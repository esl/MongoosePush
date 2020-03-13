defmodule PhxSimpleHandlerTest do
  use ExUnit.Case, async: false

  alias HTTPoison.Response

  setup do
    TestHelper.reload_app()
  end

  test "simple HTTP POST request returns 200" do
    assert 200 = post("/simple", %{service: :fcm, body: "body", title: "title"})
  end

  defp post(path, json) do
    %Response{status_code: status_code} =
      HTTPoison.post!(
        "http://localhost:8445" <> path,
        Poison.encode!(json),
        [{"Content-Type", "application/json"}],
        hackney: [:insecure]
      )

    status_code
  end
end
