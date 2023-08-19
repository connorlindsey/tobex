defmodule TobexWeb.ListLive do
  use TobexWeb, :live_view

  alias Tobex.Library
  alias Tobex.Library.{List, Item}

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} class="" phx-submit="submit" phx-change="validate">
      <h2 class="text-base font-bold -mb-5">List</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-x-2 gap-y-6">
        <.input field={@form[:name]} type="text" label="Name" placeholder="To be x" />
        <.input field={@form[:description]} type="text" label="Description" />
      </div>
      <fieldset>
        <legend class="text-base font-bold -mb-1">Items</legend>
        <div class="space-y-2">
          <.inputs_for :let={item_form} field={@form[:items]}>
            <.input field={item_form[:id]} type="hidden" />
            <div class="flex flex-row items-start gap-2">
              <div class="grow -mt-1">
                <.input field={item_form[:name]} type="text" label="Name" />
              </div>
              <div class="grow -mt-1">
                <.input field={item_form[:url]} type="text" label="URL" />
              </div>
              <div class="grow -mt-1">
                <.input
                  field={item_form[:status]}
                  type="select"
                  label="Status"
                  options={[New: "new", "In Progress": "in_progress", Done: "done"]}
                />
              </div>
              <.button
                type="button"
                variant="danger"
                phx-click="delete-item"
                phx-value-idx={item_form.index}
                class="mt-6"
              >
                <.icon name="hero-trash" class="w-4 h-4" />
                <span class="sr-only">Delete item</span>
              </.button>
            </div>
          </.inputs_for>
          <.button class="mt-2 w-full" variant="secondary" type="button" phx-click="add-item">
            Add item
          </.button>
        </div>
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

  def mount(%{"id" => id}, _session, socket) do
    list = Library.get_list!(id)
    changeset = Library.change_list(list)

    {:ok, assign(socket, form: to_form(changeset), list_id: id)}
  end

  def mount(_params, _session, socket) do
    list_changeset =
      Library.change_list(%List{
        items: []
      })

    {:ok, assign(socket, form: to_form(list_changeset))}
  end

  def handle_event("add-item", _params, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing_items = Ecto.Changeset.get_assoc(changeset, :items)

        changeset
        |> Ecto.Changeset.change(items: existing_items ++ [Library.change_item(%Item{})])
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("delete-item", %{"idx" => idx}, socket) do
    idx = String.to_integer(idx)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        filtered_items = Ecto.Changeset.get_assoc(changeset, :items) |> Elixir.List.delete_at(idx)

        changeset
        |> Ecto.Changeset.put_assoc(:items, filtered_items)
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("validate", %{"list" => list_params}, socket) do
    form =
      Library.change_list(%List{}, list_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"list" => list_params}, socket) do
    if socket.assigns.list_id do
      with list <- Library.get_list!(socket.assigns.list_id),
           {:ok, new_list} <- Library.update_list(list, list_params) do
        {:noreply,
         socket
         |> put_flash(:info, "List updated successfully.")
         |> redirect(to: ~p"/lists/#{new_list}")}
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :form, to_form(Map.put(changeset, :action, :update)))}
      end
    else
      case Library.create_list(socket.assigns.current_user, list_params) do
        {:ok, list} ->
          {:noreply,
           socket
           |> put_flash(:info, "List created successfully.")
           |> redirect(to: ~p"/lists/#{list}")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :form, to_form(Map.put(changeset, :action, :insert)))}
      end
    end
  end
end
