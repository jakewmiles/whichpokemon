defmodule WhichpokemonWeb.PageLive do
  use Surface.LiveView

  @impl true
  def render(assigns) do
    ~F"""
      <h1>Pagelive works!</h1>
    """
  end

end
