import Config

config :github_ex, :github, %{base_url: "https://api.github.com", user_agent: "GithubEx"}

config :github_ex, :tesla_client, Tesla

import_config "#{config_env()}.exs"
