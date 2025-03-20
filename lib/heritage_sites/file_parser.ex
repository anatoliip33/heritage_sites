defmodule HeritageSites.FileParser do
  @required_fields [
    "unique_number",
    "id_no",
    "category",
    "date_inscribed",
    "longitude",
    "latitude",
    "area_hectares"
  ]
  @lang_fields ["name", "short_description", "justification", "states_name", "region"]

  @doc """
  Parses CSV file into a list of maps with corresponding keys and values.
  Also filter by lang and keys in maps if they present in query string,
  example `api/locations?lang=en&query_params=date_end,rev_bis&from=10&size=5`

  ## Examples
      iex> params = %{"lang" => "en", "query_params" => "date_end,rev_bis"}
      iex> file_path = Path.expand("priv/data/", File.cwd!()) |> Path.join("whc-sites.csv")
      iex> size = 5
      iex> from = 10
      iex> HeritageSites.FileParser.parse_file(file_path, params, from, size) |> List.first() |> Map.has_key?("name_en")
      true
      iex> HeritageSites.FileParser.parse_file(file_path, params, from, size) |> List.first() |> Map.has_key?("date_end")
      true
      iex> HeritageSites.FileParser.parse_file(file_path, %{}, 0, 0) |> Enum.count()
      1199
  """
  def parse_file(file_path, params, from, size) do
    file_path
    |> File.stream!([:trim_bom])
    |> CSV.decode!(headers: true, escape_max_lines: 20)
    |> Stream.map(fn site ->
      filter_by_params(params, site)
    end)
    |> Stream.drop(from)
    |> add_size(size)
    |> Enum.to_list()
  end

  defp filter_by_params(params, site) when params == %{}, do: site

  defp filter_by_params(%{"lang" => lang, "query_params" => query_params}, site) do
    site
    |> Map.take(
      @required_fields
      |> Enum.concat(
        add_lang_param(lang)
        |> Enum.concat(add_query_params(query_params))
      )
    )
  end

  defp filter_by_params(%{"lang" => lang}, site) do
    site
    |> Map.take(
      @required_fields
      |> Enum.concat(add_lang_param(lang))
    )
  end

  defp filter_by_params(%{"query_params" => query_params}, site) do
    site
    |> Map.take(
      @required_fields
      |> Enum.concat(add_query_params(query_params))
    )
  end

  defp add_query_params(query_params) do
    query_params
    |> String.split(",")
  end

  defp add_lang_param(lang) do
    @lang_fields
    |> Enum.map(&"#{&1}_#{lang}")
  end

  defp add_size(streams, size) when is_integer(size) and size > 0 do
    streams
    |> Stream.take(size)
  end

  defp add_size(streams, _), do: streams
end
