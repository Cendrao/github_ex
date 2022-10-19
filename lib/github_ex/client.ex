defmodule GithubEx.Client do
  @moduledoc """
  Github Tesla client.

  It handles the HTTP calls to Github API. Can be used to make a request that is
  not implemented on the library.

  It always add the following default headers:

    * `{"User-Agent", "Githubex"}`
    * `{"Accept", "application/vnd.github+json"}`
  """

  alias GithubEx.Configuration

  @doc """
  Makes a GET request to the given URL considering the configuration in config.exs 
  for the base URL.

  It is possible to pass the access token as option for authenticated requests.

  ## Options

    * `access_token` - will add the Authorization header to the request with Bearer <token> as the value.

  ## Examples

      iex> GithubEx.Client.get("/licenses")
      iex> {:ok, %Tesla.Env{status: 200, body: "Licences response body"}}
  """
  @spec get(String.t(), keyword()) :: Tesla.Env.result()
  def get(url, opts) do
    Tesla.get(client(opts), url)
  end

  defp client(opts) do
    config = Configuration.fetch(opts)

    headers = config |> build_headers() |> maybe_add_authorization_header(opts)

    middleware = [
      {Tesla.Middleware.BaseUrl, config.base_url},
      {Tesla.Middleware.Headers, headers},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  defp build_headers(config) do
    [{"User-Agent", config.user_agent}, {"Accept", "application/vnd.github+json"}]
  end

  defp maybe_add_authorization_header(headers, opts) do
    case Keyword.get(opts, :access_token) do
      nil ->
        headers

      access_token ->
        headers ++ [{"Authorization", "Bearer #{access_token}"}]
    end
  end
end
