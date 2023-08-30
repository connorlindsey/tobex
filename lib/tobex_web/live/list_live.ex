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
        placeholder="Name"
        class="text-2xl leading-paper-line-2x font-semibold text-gray-900 -mb-1"
      />
      <.inline_input
        type="textarea"
        field={@form[:description]}
        label="Description"
        placeholder="Description"
        rows="2"
        class="resize-none -mb-0.5"
      />
      <fieldset class="mt-paper-line -mb-1.5">
        <legend class="font-bold">Items</legend>
        <div>
          <.inputs_for :let={item_form} field={@form[:items]}>
            <div class="flex flex-row items-start gap-2 relative">
              <.inline_input type="hidden" name="list[items_sort][]" value={item_form.index} />
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
              <label class="flex items-center justify-center hover:text-red-500 active:text-red-800 mt-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  name="list[items_drop][]"
                  value={item_form.index}
                  class="sr-only"
                />
                <.icon name="hero-trash" class="w-4 h-4" />
                <span class="sr-only">Delete item</span>
              </label>
            </div>
          </.inputs_for>
          <label class="flex items-center gap-1 hover:text-gray-700 active:text-gray-900 cursor-pointer">
            <input type="checkbox" name="list[items_sort][]" class="sr-only" />
            <.icon name="hero-plus" class="w-4 h-4" /> Add item
          </label>
        </div>
      </fieldset>
      <div class="flex items-center justify-between mt-paper-line">
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
          :if={Map.get(assigns, :list_id) != nil}
          href={~p"/lists/#{Map.get(assigns, :list_id)}"}
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

  def handle_event("validate", %{"list" => list_params}, socket) do
    form =
      Library.change_list(%List{}, list_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"list" => list_params}, socket) do
    # If there are no items, there's no field on the list_params, so set to
    # an empty list so all associated items to the list are deleted.
    list_params =
      if Map.get(list_params, "items") == nil do
        Map.put(list_params, "items", [])
      else
        list_params
      end

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
