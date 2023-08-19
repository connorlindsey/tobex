defmodule TobexWeb.ListController do
  use TobexWeb, :controller

  alias Tobex.Library

  plug :fetch_list when action in [:show, :delete]
  plug :require_owner when action in [:show, :delete]

  def index(conn, _params) do
    lists = Library.list_lists_for_user(conn.assigns[:current_user].id)
    render(conn, :index, lists: lists)
  end

  def show(conn, _params) do
    render(conn, :show, list: conn.assigns[:list])
  end

  def delete(conn, _params) do
    {:ok, _list} = Library.delete_list(conn.assigns[:list])

    conn
    |> put_flash(:info, "List deleted successfully.")
    |> redirect(to: ~p"/lists")
  end

  defp fetch_list(conn, _opts) do
    list = Library.get_list!(conn.params["id"])
    assign(conn, :list, list)
  end

  defp require_owner(conn, _opts) do
    if conn.assigns.list && conn.assigns[:list].user_id == conn.assigns[:current_user].id do
      conn
    else
      conn |> put_flash(:error, "You can't access that page") |> redirect(to: ~p"/") |> halt()
    end
  end
end
