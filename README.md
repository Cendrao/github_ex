# GithubEx

A Elixir client to Github API.

This is an educational project use it in your project at your own discretion since it may not follow all the security guidelines necessary for production code.

The purpose of this project is practice creating an API and study some practices and uses of Elixir language.

## Installation

This library is not available on hex, but you can install it using Github as follows:

```elixir
def deps do
  [
    {:github_ex, github: "cendrao/github_ex"},
  ]
end
```

## Useful information

The goal of the project is to practice how to implement a client for an API and study the main pros and cons of each approach and decision that was made, the first decision was to use [Tesla](https://github.com/elixir-tesla/tesla) as the HTTP client because its interface is very simple to use and it abstracts lots of complexity helping to focus on the Client design.
