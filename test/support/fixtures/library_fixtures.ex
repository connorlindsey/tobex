defmodule Tobex.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tobex.Library` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    {:ok, list} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description"
      })
      |> Tobex.Library.create_list()

    list
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        name: "some name",
        status: "some status"
      })
      |> Tobex.Library.create_item()

    item
  end
end
