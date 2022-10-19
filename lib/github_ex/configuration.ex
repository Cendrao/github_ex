defmodule GithubEx.Configuration do
  @moduledoc """
  Handles and fetches the configuration option for GithubEx.
  """

  defmodule ConfigurationError do
    defexception [:reason, :key]

    def message(%__MODULE__{reason: :missing_key, key: key}),
      do: "Github Configuration Error - Missing key #{key}"
  end

  def fetch(opts) do
    config = Application.get_env(:github_ex, :github)

    base_url = Keyword.get(opts, :base_url, from_config!(config, :base_url))
    user_agent = Keyword.get(opts, :user_agent, from_config!(config, :user_agent))

    %{
      base_url: base_url,
      user_agent: user_agent
    }
  end

  defp from_config!(config, key) do
    Map.get(config, key) || raise %ConfigurationError{reason: :missing_key, key: key}
  end
end
