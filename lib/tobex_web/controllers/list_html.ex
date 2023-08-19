defmodule TobexWeb.ListHTML do
  use TobexWeb, :html

  embed_templates "list_html/*"

  # Convert string to title case
  defp to_title(str) do
    str
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
