defmodule TobexWeb.AdminController do
  use TobexWeb, :controller

  alias Tobex.{Library, Accounts}

  def index(conn, _params) do
    lists = Library.list_lists()
    users = Accounts.list_users()
    render(conn, :index, lists: lists, users: users)
  end
end
