defmodule Tobex.LibraryTest do
  use Tobex.DataCase

  alias Tobex.Library
  alias Tobex.Accounts.User

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

      assert {:ok, %List{} = list} = Library.create_list(%User{}, valid_attrs)
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

  describe "items" do
    alias Tobex.Library.Item

    import Tobex.LibraryFixtures

    @invalid_attrs %{name: nil, status: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Library.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Library.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{name: "some name", status: "some status"}

      assert {:ok, %Item{} = item} = Library.create_item(valid_attrs)
      assert item.name == "some name"
      assert item.status == "some status"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status"}

      assert {:ok, %Item{} = item} = Library.update_item(item, update_attrs)
      assert item.name == "some updated name"
      assert item.status == "some updated status"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_item(item, @invalid_attrs)
      assert item == Library.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Library.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Library.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Library.change_item(item)
    end
  end
end
