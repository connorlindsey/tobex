defmodule TobexWeb.ListLive do
  use TobexWeb, :live_view

  alias Tobex.Library
  alias Tobex.Library.{List, Item}

  # TODO: Auto-save
  # Potential solution: https://janezurevc.name/real-time-auto-save-phoenix-liveview/
  # Potential: Use phx-debunce on each input and save from validation (need to handle new vs. edit)
  # Minimally show that changes were saved
  def render(assigns) do
    ~H"""
    <.form
      for={@form}
      phx-submit="submit"
      phx-change="validate"
      class="shadow border rounded border-gray-900/10 bg-white text-gray-600 pb-paper-line pt-2 px-4 bg-opacity-50 bg-repeat-paper leading-paper-line"
    >
      <.inline_input
        field={@form[:name]}
        type="text"
        label="Name"
        placeholder="To be x"
        class="text-2xl leading-paper-line-2x font-semibold text-gray-900"
      />
      <.inline_input
        type="textarea"
        field={@form[:description]}
        label="Description"
        placeholder="Description"
        rows="2"
        class="resize-none -mb-1.5"
        phx-debounce="2000"
      />
      <fieldset class="mt-paper-line">
        <div class="flex items-center justify-between">
          <legend class="font-bold">Items</legend>
          <button
            variant="secondary"
            type="button"
            phx-click="add-item"
            class="flex items-center gap-1 hover:text-gray-700 active:text-gray-900"
          >
            <.icon name="hero-plus" class="w-4 h-4" /> Add item
          </button>
        </div>
        <div>
          <.inputs_for :let={item_form} field={@form[:items]}>
            <%!-- Include the id field in the form for editing purposes --%>
            <.inline_input :if={item_form.data.id != nil} field={item_form[:id]} type="hidden" />
            <div class="flex flex-row items-start gap-2 relative">
              <div class="flex-shrink-0">
                <.inline_input
                  field={item_form[:status]}
                  type="select"
                  label="Status"
                  options={["🆕 New": "new", "🟡 In Progress": "in_progress", "✅ Done": "done"]}
                  class="pr-8"
                />
              </div>
              <div class="w-full">
                <.inline_input field={item_form[:name]} type="text" label="Name" placeholder="Name" />
              </div>
              <div class="w-full">
                <.inline_input
                  field={item_form[:url]}
                  type="text"
                  label="URL"
                  placeholder="URL (Optional)"
                  class=""
                />
              </div>
              <button
                type="button"
                phx-click="delete-item"
                phx-value-idx={item_form.index}
                class="flex items-center justify-center hover:text-red-500 active:text-red-800 mt-1.5"
              >
                <.icon name="hero-trash" class="w-4 h-4" />
                <span class="sr-only">Delete item</span>
              </button>
            </div>
          </.inputs_for>
        </div>
      </fieldset>
      <div class="flex items-center justify-between mt-paper-line pt-0.5">
        <div class="flex items-center gap-x-4 -ml-3">
          <.button variant="inline" phx-disable-with="Saving...">Save list</.button>
          <.link
            navigate={~p"/lists"}
            class="text-sm font-semibold leading-6 text-gray-500 hover:text-gray-700"
          >
            Cancel
          </.link>
        </div>
        <.link
          :if={@form.data.id != nil}
          href={~p"/lists/#{@form.data.id}"}
          method="DELETE"
          class="text-sm font-semibold leading-6 text-gray-500 hover:text-gray-700"
        >
          Delete list
        </.link>
      </div>
    </.form>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    list = Library.get_list!(id)
    changeset = Library.change_list(list)

    {:ok, assign(socket, form: to_form(changeset), list_id: id)}
  end

  def mount(_params, _session, socket) do
    list_changeset =
      Library.change_list(%List{})
      |> Ecto.Changeset.change(items: [Library.change_item(%Item{})])

    {:ok, assign(socket, form: to_form(list_changeset))}
  end

  def handle_event("add-item", _params, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing_items = Ecto.Changeset.get_assoc(changeset, :items)

        IO.inspect(existing_items, label: "Add item - existing Items")

        changeset
        |> Ecto.Changeset.change(items: existing_items ++ [Library.change_item(%Item{})])
        |> to_form()
      end)

    {:noreply, socket}
  end

  # TODO: Fix deleting multiple items consecutively (only affects edit)
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
    if socket.assigns.live_action == :edit && socket.assigns.list_id do
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
