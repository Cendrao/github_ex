defmodule GithubEx.RepositoriesTest do
  use ExUnit.Case

  import GithubEx.FixtureHelper

  alias GithubEx.Repositories
  alias GithubEx.Repositories.Repository

  describe "fetch/2" do
    test "returns a repository" do
      Tesla.Mock.mock(fn
        %{method: :get} ->
          %Tesla.Env{
            status: 200,
            body: read_fixture_file_as_map!("/repositories/elixir-lang_elixir.json")
          }
      end)

      assert {:ok, %Repository{} = repository} = Repositories.fetch("elixir-lang", "elixir")

      assert repository.full_name == "elixir-lang/elixir"
      assert repository.id == 1_234_714
      assert repository.url == "https://api.github.com/repos/elixir-lang/elixir"
      assert repository.name == "elixir"
      assert repository.language == "Elixir"
    end

    test "when the repository does not exist returns 404 with error" do
      error_body =
        "{\"message\":\"Not Found\",\"documentation_url\":\"https://docs.github.com/rest/reference/repos#get-a-repository\"}"

      Tesla.Mock.mock(fn
        %{method: :get} ->
          %Tesla.Env{status: 404, body: Jason.decode!(error_body)}
      end)

      assert {:error, [404, error]} = Repositories.fetch("non-existant", "repository")
      assert error["message"] == "Not Found"
    end
  end
end
