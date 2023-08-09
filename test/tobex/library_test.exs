defmodule Tobex.LibraryTest do
  use Tobex.DataCase

  alias Tobex.Library

  describe "lists" do
    alias Tobex.Library.List

    import Tobex.LibraryFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert Library.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Library.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %List{} = list} = Library.create_list(valid_attrs)
      assert list.name == "some name"
      assert list.description == "some description"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %List{} = list} = Library.update_list(list, update_attrs)
      assert list.name == "some updated name"
      assert list.description == "some updated description"
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_list(list, @invalid_attrs)
      assert list == Library.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Library.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Library.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Library.change_list(list)
    end
  end
end
