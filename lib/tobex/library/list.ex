defmodule Tobex.Library.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    field :description, :string
    # TODO: Add items to lists
    # TODO: Add status to items

    belongs_to :user, Tobex.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
