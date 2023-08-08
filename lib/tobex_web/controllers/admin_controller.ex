defmodule TobexWeb.AdminController do
  use TobexWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
