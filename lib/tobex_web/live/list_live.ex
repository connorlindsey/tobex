defmodule TobexWeb.ListLive do
  use TobexWeb, :live_view

  alias Tobex.Library
  alias Tobex.Library.{List, Item}

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} class="max-w-xl" phx-submit="submit" phx-change="validate">
      <%!-- TODO: Handle errors with .error --%>
      <h2 class="text-base font-bold -mb-4">List</h2>
      <.input field={@form[:name]} type="text" label="Name" placeholder="To be x" />
      <.input field={@form[:description]} type="text" label="Description" />
      <fieldset>
        <legend class="text-base font-bold mb-2">Items</legend>
        <.inputs_for :let={item_form} field={@form[:items]}>
          <div class="flex flex-row items-end gap-2">
            <div class="grow">
              <.input field={item_form[:name]} type="text" label="Name" />
            </div>
            <div class="grow">
              <.input field={item_form[:url]} type="text" label="URL" />
            </div>
            <div class="grow">
              <.input field={item_form[:status]} type="text" label="Status" />
            </div>
            <.button type="button" variant="danger">
              <.icon name="hero-trash" class="w-4 h-4" />
              <%!-- TODO: handle removing an item --%>
              <span class="sr-only">Delete item</span>
            </.button>
          </div>
        </.inputs_for>
        <.button class="mt-2 w-full" variant="secondary" type="button" phx-click="add-item">
          Add item
        </.button>
      </fieldset>
      <:actions>
        <.button phx-disable-with="Saving...">Save list</.button>
        <.link
          navigate={~p"/lists"}
          class="text-sm font-semibold leading-6 text-gray-900 hover:text-gray-700"
        >
          Cancel
        </.link>
      </:actions>
    </.simple_form>
    """
  end

  # TODO: Handle edit in mount and events
  # def mount(%{"id" => _id}, _session, socket) do
  #   # Edit
  #   # def edit(conn, %{"id" => id}) do
  #   #   list = Library.get_list!(id)
  #   #   changeset = Library.change_list(list)
  #   #   render(conn, :edit, list: list, changeset: changeset)
  #   # end
  #   {:ok, socket}
  # end

  def mount(_params, _session, socket) do
    list_changeset =
      Library.change_list(%List{
        items: [
          %Item{}
        ]
      })

    {:ok, assign(socket, :form, to_form(list_changeset))}
  end

  def handle_event("add-item", _params, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing_items = Ecto.Changeset.get_assoc(changeset, :items)

        changeset
        |> Ecto.Changeset.put_assoc(:items, existing_items ++ [Library.change_item(%Item{})])
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("validate", %{"list" => list_params}, socket) do
    form =
      Library.change_list(%List{items: []}, list_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", params, socket) do
    IO.inspect(params)
    IO.inspect(socket)
    {:noreply, socket}
    # case Library.create_list(conn.assigns.current_user, list_params) do
    #   {:ok, list} ->
    #     conn
    #     |> put_flash(:info, "List created successfully.")
    #     |> redirect(to: ~p"/lists/#{list}")

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, :new, changeset: changeset)
    # end
  end

  # def update(conn, %{"id" => id, "list" => list_params}) do
  #   list = Library.get_list!(id)

  #   case Library.update_list(list, list_params) do
  #     {:ok, list} ->
  #       conn
  #       |> put_flash(:info, "List updated successfully.")
  #       |> redirect(to: ~p"/lists/#{list}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :edit, list: list, changeset: changeset)
  #   end
  # end
end
