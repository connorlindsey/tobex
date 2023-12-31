defmodule Tobex.Library.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :url, :string
    field :status, :string

    belongs_to :list, Tobex.Library.List

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :url, :status])
    |> validate_required([:name, :status], message: "Required")
  end
end
