defmodule WhichpokemonWeb.PageLive do
  use Surface.LiveView
  alias Whichpokemon.Pokefetcher

  @impl true
  def mount(_params, _session, socket) do 
    {:ok, 
      socket
      |> assign(generations: [1,2,3,4,5,6,7,8])
    }
  end

  @impl true
  def render(assigns) do
    ~F"""
      <h1>Welcome!</h1>
      <h3>Which generation of Pokemon would you like to practice with?</h3>
      {#for generation <- @generations}
        <button phx-value-gen={generation} phx-click="go_to_game">{generation}</button>
      {/for}
    """
  end

  @impl true
  def handle_event("go_to_game", params, socket) do
    %{"gen" => gen} = params
    {:noreply, push_redirect(socket, to: "/game/" <> gen)}
  end

end
