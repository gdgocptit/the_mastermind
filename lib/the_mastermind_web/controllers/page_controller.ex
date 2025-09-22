defmodule TheMastermindWeb.PageController do
  use TheMastermindWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
