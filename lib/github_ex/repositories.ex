defmodule GithubEx.Repositories do
  alias GithubEx.Client
  alias GithubEx.Repositories.Repository

  def fetch(repository_name) do
    [owner, name] = normalize_repository_name(repository_name)
    fetch(owner, name)
  end

  def fetch(owner, name) do
    case Client.get("/repos/#{owner}/#{name}") do
      {:ok, %{status: 200, body: body}} ->
        repo =
          body
          |> with_atom_keys()
          |> as_struct(Repository)

        {:ok, repo}

      {:ok, %{status: status, body: body}} ->
        {:error, [status, body]}

      {:error, error} ->
        {:error, error}
    end
  end

  defp normalize_repository_name(repository_name) do
    String.split(repository_name, "/")
  end

  defp with_atom_keys(attrs) do
    attrs
    |> Enum.map(fn {k, v} ->
      {String.to_existing_atom(k), v}
    end)
    |> Enum.into(%{})
  end

  def as_struct(attrs, struct) do
    struct(struct, attrs)
  end
end
