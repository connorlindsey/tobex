defmodule TobexWeb.ListController do
  use TobexWeb, :controller

  alias Tobex.Library
  alias Tobex.Library.List

  def index(conn, _params) do
    lists = Library.list_lists()
    render(conn, :index, lists: lists)
  end

  def new(conn, _params) do
    changeset = Library.change_list(%List{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"list" => list_params}) do
    case Library.create_list(conn.assigns.current_user, list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: ~p"/lists/#{list}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    list = Library.get_list!(id)
    render(conn, :show, list: list)
  end

  def edit(conn, %{"id" => id}) do
    list = Library.get_list!(id)
    changeset = Library.change_list(list)
    render(conn, :edit, list: list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    list = Library.get_list!(id)

    case Library.update_list(list, list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: ~p"/lists/#{list}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, list: list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = Library.get_list!(id)
    {:ok, _list} = Library.delete_list(list)

    conn
    |> put_flash(:info, "List deleted successfully.")
    |> redirect(to: ~p"/lists")
  end
end
