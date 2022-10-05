defmodule GithubEx.Repositories do
  @moduledoc """
  Holds functions that work with a Repository, which is the main Github entity.

  For now it only has a few functions for fetching or listing repositories.
  """

  alias GithubEx.Client
  alias GithubEx.Repositories.Repository

  @doc """
  Fetches and returns a Repository.

  Given a repository name as a string in the patter `owner/name` will fetch the 
  repository on GitHub and return it structure or an error if the request is not
  successful.

  ## Examples

      iex> Repositories.fetch("elixir-lang/elixir")
      iex> {:ok, %GithubEx.Repositories.Repository{
        labels_url: "https://api.github.com/repos/elixir-lang/elixir/labels{/name}",
        keys_url: "https://api.github.com/repos/elixir-lang/elixir/keys{/key_id}",
        fork: false...
        }
      }

      iex> Repositories.fetch("invalid-repo")
      iex> {:error, :invalid_name}
  """
  @spec fetch(String.t()) :: {:ok, Repository.t()} | {:error, any()}
  def fetch(repository_name) do
    case normalize_repository_name(repository_name) do
      [owner, name] ->
        fetch(owner, name)

      _ ->
        {:error, :invalid_name}
    end
  end

  @doc """
  Fetches and returns a Repository.

  Given the owner and the name of a repository it  will fetch the repository on
  GitHub and return it structure or an error if the request is not successful.

  ## Examples

      iex> Repositories.fetch("elixir-lang", "elixir")
      iex> {:ok, %GithubEx.Repositories.Repository{
        labels_url: "https://api.github.com/repos/elixir-lang/elixir/labels{/name}",
        keys_url: "https://api.github.com/repos/elixir-lang/elixir/keys{/key_id}",
        fork: false...
        }
      }

      iex> Repositories.fetch("invalid", "repo")
      iex> {:error, [404, "Not found"]}

  """
  @spec fetch(String.t(), String.t()) :: {:ok, Repository.t()} | {:error, any()}
  def fetch(owner, name) do
    case Client.get("/repos/#{owner}/#{name}") do
      {:ok, %{status: 200, body: body}} ->
        repo = to_struct(body)
        {:ok, repo}

      context ->
        handle_error(context)
    end
  end

  @doc """
  Lists all public repositories in the order that they were created.

  Returns a list of Repositories from GitHub or error in case the requests fails.

  ## Examples

      iex> Repositories.list()
      iex> {:ok, [%GithubEx.Repositories.Repository{
        labels_url: "https://api.github.com/repos/elixir-lang/elixir/labels{/name}",
        keys_url: "https://api.github.com/repos/elixir-lang/elixir/keys{/key_id}",
        fork: false...
        }]
      }

      iex> Repositories.list()
      iex> {:error, [500, "Internal Server Error"]}
  """
  @spec list() :: {:ok, list(Repository.t())} | {:error, any()}
  def list do
    case Client.get("/repositories") do
      {:ok, %{status: 200, body: body}} ->
        repos = Enum.map(body, &to_struct/1)
        {:ok, repos}

      context ->
        handle_error(context)
    end
  end

  @doc """
  Lists a user Repositories.

  Given a user name it fetches and returns a list of repositories from the given
  user and will return an error in case the requests fails.

  ## Examples

      iex> Repositories.list_by_user("elixir-lang")
      iex> {:ok, [%GithubEx.Repositories.Repository{
        labels_url: "https://api.github.com/repos/elixir-lang/elixir/labels{/name}",
        keys_url: "https://api.github.com/repos/elixir-lang/elixir/keys{/key_id}",
        fork: false...
        }]
      }

      iex> Repositories.list_by_user("notexistinguser")
      iex> {:error, [404, "Not found"]}
  """
  @spec list_by_user(String.t()) :: {:ok, list(Repository.t())} | {:error, any()}
  def list_by_user(username) do
    case Client.get("/users/#{username}/repos") do
      {:ok, %{status: 200, body: body}} ->
        repos = Enum.map(body, &to_struct/1)
        {:ok, repos}

      context ->
        handle_error(context)
    end
  end

  defp normalize_repository_name(repository_name) do
    String.split(repository_name, "/")
  end

  defp to_struct(attrs) do
    attrs = with_atom_keys(attrs)
    struct(Repository, attrs)
  end

  defp with_atom_keys(attrs) do
    attrs
    |> Enum.map(fn {k, v} ->
      {String.to_existing_atom(k), v}
    end)
    |> Enum.into(%{})
  end

  defp handle_error(context) do
    case context do
      {:ok, %{status: status, body: body}} ->
        {:error, [status, body]}

      {:error, error} ->
        {:error, error}
    end
  end
end
