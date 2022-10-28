import Config

config :github_ex, :github, %{base_url: "http://localhost", user_agent: "GithubEx.Test"}

config :tesla, adapter: Tesla.Mock
