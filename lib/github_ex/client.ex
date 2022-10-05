defmodule GithubEx.Client do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.github.com")
  plug(Tesla.Middleware.Headers, default_headers())
  plug(Tesla.Middleware.JSON)

  defp default_headers do
    [{"User-Agent", "Githubex"}]
  end
end
