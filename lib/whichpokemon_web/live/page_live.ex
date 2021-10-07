defmodule WhichpokemonWeb.PageLive do
  use Surface.LiveView
  alias Whichpokemon.Pokefetcher
  require Logger

  @impl true
  def mount(_params, _session, socket) do 
    case connected?(socket) do
      true ->
        list = Pokefetcher.fetch_list(151, 0)
        choices = Enum.take_random(list, 4)
        list_names = Enum.map(choices, fn %{"name" => name} -> 
          [name] 
        end)
        selected = Enum.random(choices)
        %{"url" => selected_url, "name" => selected_name} = selected
        selected_data = Pokefetcher.fetch_pokemon(selected_url)
        %{"sprites" => %{"other" => %{"official-artwork" => %{"front_default" => front_default}}}} = selected_data 
        {:ok, 
          socket
          |> assign(list_names: list_names)
          |> assign(selected_name: selected_name)
          |> assign(front_default: front_default)
        }
      false ->
        {:ok,
          socket
          |> assign(list_names: [])
          |> assign(selected_name: "loading")
          |> assign(front_default: "")}
      end
  end

  @impl true
  def render(assigns) do
    ~F"""
      {#for name <- @list_names}
      <button phx-value-id={name} phx-click="guess">{name}</button>
      {/for}
      <img src={@front_default} />
    """
  end

end
