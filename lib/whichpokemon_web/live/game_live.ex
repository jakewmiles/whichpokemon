defmodule WhichpokemonWeb.GameLive do
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
  def mount(params, _session, socket) do 
    
    %{"gen" => gen} = params
    Logger.info(gen)

    list = case String.to_integer(gen) do
      1 -> Pokefetcher.fetch_list(151, 0)
      2 -> Pokefetcher.fetch_list(100, 151)
      3 -> Pokefetcher.fetch_list(135, 251)
      4 -> Pokefetcher.fetch_list(107, 386)
      5 -> Pokefetcher.fetch_list(156, 493)
      6 -> Pokefetcher.fetch_list(72, 649)
      7 -> Pokefetcher.fetch_list(88, 721)
      8 -> Pokefetcher.fetch_list(92, 809)
    end
    case connected?(socket) do
      true ->
        fetched = get_assigns(list)
        {:ok, 
          socket
          |> assign(guessed: false)
          |> assign(score: 0)
          |> assign(list_choices: fetched.list_choices)
          |> assign(selected_name: fetched.selected_name)
          |> assign(front_default: fetched.front_default)
          |> assign(leftovers: fetched.leftovers)
        }
      false ->
        {:ok,
          socket
          |> assign(guessed: false)
          |> assign(score: 0)
          |> assign(list_choices: [])
          |> assign(selected_name: "")
          |> assign(front_default: "")
          |> assign(leftovers: [])
        }
      end
  end

  @impl true
  def render(assigns) do
    ~F"""
      <div class="game-container">
        <h1>Score: {@score}</h1>
        {#for name <- @list_choices}
          <button phx-value-id={name} phx-click="guess">{name}</button>
        {/for}
        <div class="image-container">
          <img src={@front_default} />
        </div>
        
        <button phx-click="home">Go back!</button>
        
      </div>
    """
  end

  @impl true
  def handle_event("guess", params, socket) do
    %{"id" => guess} = params
    new_game = get_assigns(socket.assigns.leftovers)
    case guess == socket.assigns.selected_name do
      true -> 
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
          |> assign(list_choices: new_game.list_choices)
          |> assign(selected_name: new_game.selected_name)
          |> assign(front_default: new_game.front_default)
          |> assign(leftovers: new_game.leftovers)
        }
    end
  end

  @impl true
  def handle_event("home", _params, socket) do
    {:noreply, push_redirect(socket, to: "/")}
  end

end
