defmodule Tobex.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false
      add :url, :string
      add :status, :string, null: false
      add :list_id, references(:lists, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:list_id])
  end
end
