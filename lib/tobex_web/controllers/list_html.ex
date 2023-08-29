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

  defp status_to_emoji(status) do
    case status do
      "new" -> "🆕"
      "in_progress" -> "🟡"
      "done" -> "✅"
      _ -> "🔲"
    end
  end

  defp is_valid_url(url) do
    uri = URI.parse(url)
    uri.scheme != nil && uri.host =~ "."
  end
end
