defmodule WhichpokemonWeb.PageLive do
  use Surface.LiveView
  alias Whichpokemon.Pokefetcher
  require Logger

  def get_assigns(list) do
    choices = Enum.take_random(list, 4)
    list_choices = Enum.map(choices, fn %{"name" => name} -> 
      [name] 
    end)
    selected = Enum.random(choices)
    leftovers = Enum.filter(list, fn x -> x != selected end)
    %{"url" => selected_url, "name" => selected_name} = selected
    selected_data = Pokefetcher.fetch_pokemon(selected_url)
    %{"sprites" => %{"other" => %{"official-artwork" => %{"front_default" => front_default}}}} = selected_data 
    %{list_choices: list_choices, selected_name: selected_name, front_default: front_default, leftovers: leftovers}
  end

  @impl true
  def mount(_params, _session, socket) do 
    list = Pokefetcher.fetch_list(10, 0)
    case connected?(socket) do
      true ->
        fetched = get_assigns(list)
        {:ok, 
          socket
          |> assign(score: 0)
          |> assign(list_choices: fetched.list_choices)
          |> assign(selected_name: fetched.selected_name)
          |> assign(front_default: fetched.front_default)
          |> assign(leftovers: fetched.leftovers)
        }
      false ->
        {:ok,
          socket
          |> assign(score: 0)
          |> assign(list_choices: [])
          |> assign(selected_name: "loading")
          |> assign(front_default: "")
          |> assign(leftovers: [])
        }
      end
  end

  @impl true
  def render(assigns) do
    ~F"""
      <h1>Score: {@score}</h1>
      {#for name <- @list_choices}
      <button phx-value-id={name} phx-click="guess">{name}</button>
      {/for}
      <img src={@front_default} />
    """
  end

  def handle_event("guess", params, socket) do
    %{"id" => guess} = params

    new_game = get_assigns(socket.assigns.leftovers)
    case guess == socket.assigns.selected_name do
      true -> 
        Logger.info(new_game)
        {:noreply, 
          socket
          |> assign(score: socket.assigns.score + 1)
          |> assign(list_choices: new_game.list_choices)
          |> assign(selected_name: new_game.selected_name)
          |> assign(front_default: new_game.front_default)
          |> assign(leftovers: new_game.leftovers)
        }
      false ->
        {:noreply, 
          socket
          |> assign(score: socket.assigns.score)
          |> assign(list_choices: new_game.list_choices)
          |> assign(selected_name: new_game.selected_name)
          |> assign(front_default: new_game.front_default)
          |> assign(leftovers: new_game.leftovers)
        }
    end
  end

end
