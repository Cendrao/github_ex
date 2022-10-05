defmodule GithubEx.FixtureHelper do
  def read_fixture_file!(fixture_file_name) do
    File.read!("test/fixtures" <> fixture_file_name)
  end

  def read_fixture_file_as_map!(fixture_file_name) do
    fixture_file_name
    |> read_fixture_file!()
    |> Jason.decode!()
  end
end
