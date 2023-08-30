defmodule Tobex.Library.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tobex.Library.Item

  schema "lists" do
    field :name, :string
    field :description, :string

    belongs_to :user, Tobex.Accounts.User
    # Allow replacing items from the form by setting on_replace: :delete_if_exists
    has_many :items, Tobex.Library.Item, on_replace: :delete_if_exists

    timestamps()
  end

  @doc false
  def changeset(list, attrs \\ %{}) do
    list
    |> cast(attrs, [:name, :description])
    |> validate_required([:name], message: "Please provide a name for the list")
    |> cast_assoc(:items,
      with: &Item.changeset/2,
      # Support adding and removing items from the list in a one-to-many form
      # https://hexdocs.pm/ecto/Ecto.Changeset.html#cast_assoc/3-sorting-and-deleting-from-many-collections
      sort_param: :items_sort,
      drop_param: :items_drop
    )
  end
end
