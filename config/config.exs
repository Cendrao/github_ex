import Config

config :github_ex, :github, %{base_url: "https://api.github.com"}

import_config "#{config_env()}.exs"
