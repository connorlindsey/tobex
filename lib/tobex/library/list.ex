defmodule Tobex.Library.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tobex.Library.Item

  schema "lists" do
    field :name, :string
    field :description, :string

    belongs_to :user, Tobex.Accounts.User
    has_many :items, Tobex.Library.Item

    timestamps()
  end

  @doc false
  def changeset(list, attrs \\ %{}) do
    list
    |> cast(attrs, [:name, :description])
    |> validate_required([:name], message: "Please provide a name for the list")
    |> cast_assoc(:items, with: &Item.changeset/2)
  end
end
