defmodule GithubEx.ClientTest do
  use ExUnit.Case

  alias GithubEx.Client

  describe "get/2" do
    test "should make a GET request to the given URL with default headers" do
      Tesla.Mock.mock(fn
        %{method: :get, url: "http://localhost/octocat", headers: headers} ->
          assert [
                   {"User-Agent", "GithubEx.Test"},
                   {"Accept", "application/vnd.github+json"}
                 ] == headers

          %Tesla.Env{
            status: 200,
            body: "Github Octocat!"
          }
      end)

      assert {:ok, %Tesla.Env{status: 200, body: "Github Octocat!"}} == Client.get("/octocat", [])
    end

    test "should have custom headers when given" do
      Tesla.Mock.mock(fn
        %{method: :get, url: "http://localhost/octocat", headers: headers} ->
          assert [
                   {"User-Agent", "GithubEx.Test"},
                   {"Accept", "application/vnd.github+json"},
                   {"Authorization", "Bearer A_RANDOM_ACCESS_TOKEN"}
                 ] == headers

          %Tesla.Env{
            status: 200,
            body: "Github Octocat!"
          }
      end)

      assert {:ok, %Tesla.Env{status: 200, body: "Github Octocat!"}} ==
               Client.get("/octocat", access_token: "A_RANDOM_ACCESS_TOKEN")
    end
  end
end
