defmodule GithubEx.Client do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, base_url())
  plug(Tesla.Middleware.Headers, default_headers())
  plug(Tesla.Middleware.JSON)

  defp base_url do
    github_config = Application.get_env(:github_ex, :github)

    github_config.base_url
  end

  defp default_headers do
    [{"User-Agent", "Githubex"}]
  end
end
