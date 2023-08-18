defmodule TobexWeb.ListController do
  use TobexWeb, :controller

  alias Tobex.Library

  def index(conn, _params) do
    lists = Library.list_lists()
    render(conn, :index, lists: lists)
  end

  def show(conn, %{"id" => id}) do
    list = Library.get_list!(id)
    render(conn, :show, list: list)
  end

  def delete(conn, %{"id" => id}) do
    list = Library.get_list!(id)
    {:ok, _list} = Library.delete_list(list)

    conn
    |> put_flash(:info, "List deleted successfully.")
    |> redirect(to: ~p"/lists")
  end
end
