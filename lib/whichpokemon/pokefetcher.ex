defmodule Whichpokemon.Pokefetcher do
  @url "https://pokeapi.co/api/v2/pokemon?"

  def fetch_list(limit, offset) do
    case HTTPoison.get(
           @url <> "limit=" <> Integer.to_string(limit) <> "&offset=" <> Integer.to_string(offset)
         ) do
      {:ok, %{status_code: 200, body: body}} ->
        %{"results" => list} = Poison.decode!(body)
        list

      {:ok, %{status_code: 404}} ->
        "Failed to fetch"

      {:error, _error_message} ->
        "Error during fetching"
    end
  end

  def fetch_pokemon(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode!(body)

      {:ok, %{status_code: 404}} ->
        "Failed to fetch"
    end
  end
end
