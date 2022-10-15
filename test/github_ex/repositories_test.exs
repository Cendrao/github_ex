defmodule GithubEx.RepositoriesTest do
  use ExUnit.Case

  import GithubEx.FixtureHelper

  alias GithubEx.Repositories
  alias GithubEx.Repositories.Repository

  describe "fetch/2" do
    test "returns a repository" do
      Tesla.Mock.mock(fn
        %{method: :get, url: "http://localhost/repos/elixir-lang/elixir"} ->
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
        %{method: :get, url: "http://localhost/repos/non-existant/repository"} ->
          %Tesla.Env{status: 404, body: Jason.decode!(error_body)}
      end)

      assert {:error, [404, error]} = Repositories.fetch("non-existant", "repository")
      assert error["message"] == "Not Found"
    end

    test "with an incorrect repository name" do
      assert {:error, :invalid_name} = Repositories.fetch("invalidname")
    end
  end

  describe "list/0" do
    test "returns a list of repositories" do
      Tesla.Mock.mock(fn
        %{method: :get, url: "http://localhost/repositories"} ->
          %Tesla.Env{
            status: 200,
            body: read_fixture_file_as_map!("/repositories/list.json")
          }
      end)

      assert {:ok, repositories} = Repositories.list()

      [repository1, repository2] = Enum.take(repositories, 2)

      assert repository1.full_name == "elixir-lang/elixir"
      assert repository1.id == 1_234_714
      assert repository1.url == "https://api.github.com/repos/elixir-lang/elixir"
      assert repository1.name == "elixir"
      assert repository1.language == "Elixir"

      assert repository2.full_name == "elixir-lang/elixir-lang.github.com"
      assert repository2.id == 3_569_633
      assert repository2.url == "https://api.github.com/repos/elixir-lang/elixir-lang.github.com"
      assert repository2.name == "elixir-lang.github.com"
      assert repository2.language == "CSS"
    end

    test "when github is down returns an error" do
      Tesla.Mock.mock(fn
        %{method: :get, url: "http://localhost/repositories"} ->
          %Tesla.Env{
            status: 500
          }
      end)

      assert {:error, [500, _]} = Repositories.list()
    end
  end

  describe "list_by_user/1" do
    test "given a user lists their repositories" do
      Tesla.Mock.mock(fn
        %{method: :get, url: "http://localhost/users/elixir-lang/repos"} ->
          %Tesla.Env{
            status: 200,
            body: read_fixture_file_as_map!("/repositories/list.json")
          }
      end)

      assert {:ok, repositories} = Repositories.list_by_user("elixir-lang")

      [repository1, repository2] = Enum.take(repositories, 2)

      assert repository1.full_name == "elixir-lang/elixir"
      assert repository1.id == 1_234_714
      assert repository1.url == "https://api.github.com/repos/elixir-lang/elixir"
      assert repository1.name == "elixir"
      assert repository1.language == "Elixir"

      assert repository2.full_name == "elixir-lang/elixir-lang.github.com"
      assert repository2.id == 3_569_633
      assert repository2.url == "https://api.github.com/repos/elixir-lang/elixir-lang.github.com"
      assert repository2.name == "elixir-lang.github.com"
      assert repository2.language == "CSS"
    end
  end
end
