defmodule WhichpokemonWeb.PageLive do
  use Surface.LiveView
  alias Whichpokemon.Pokefetcher
  require Logger

  def get_assigns() do
    list = Pokefetcher.fetch_list(151, 0)
    choices = Enum.take_random(list, 4)
    list_names = Enum.map(choices, fn %{"name" => name} -> 
      [name] 
    end)
    selected = Enum.random(choices)
    %{"url" => selected_url, "name" => selected_name} = selected
    selected_data = Pokefetcher.fetch_pokemon(selected_url)
    %{"sprites" => %{"other" => %{"official-artwork" => %{"front_default" => front_default}}}} = selected_data 
    %{list_names: list_names, selected_name: selected_name, front_default: front_default}
  end

  @impl true
  def mount(_params, _session, socket) do 
    case connected?(socket) do
      true ->
        fetched = get_assigns()
        {:ok, 
          socket
          |> assign(score: 0)
          |> assign(list_names: fetched.list_names)
          |> assign(selected_name: fetched.selected_name)
          |> assign(front_default: fetched.front_default)
        }
      false ->
        {:ok,
          socket
          |> assign(score: 0)
          |> assign(list_names: [])
          |> assign(selected_name: "loading")
          |> assign(front_default: "")
        }
      end
  end

  @impl true
  def render(assigns) do
    ~F"""
      <h1>Score: {@score}</h1>
      {#for name <- @list_names}
      <button phx-value-id={name} phx-click="guess">{name}</button>
      {/for}
      <img src={@front_default} />
    """
  end

  def handle_event("guess", params, socket) do
    %{"id" => guess} = params
    new_game = get_assigns()
    case guess == socket.assigns.selected_name do
      true -> 
        Logger.info("here")
        {:noreply, 
          socket
          |> assign(score: socket.assigns.score + 1)
          |> assign(list_names: new_game.list_names)
          |> assign(selected_name: new_game.selected_name)
          |> assign(front_default: new_game.front_default)
        }
      false ->
        {:noreply, 
          socket
          |> assign(score: socket.assigns.score)
          |> assign(list_names: new_game.list_names)
          |> assign(selected_name: new_game.selected_name)
          |> assign(front_default: new_game.front_default)
        }
    end
  end

end
