defmodule HeritageSitesTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn
  doctest HeritageSites.FileParser

  alias HeritageSites.Router

  @opts Router.init([])

  @csv_rows Path.expand("priv/data/", File.cwd!())
            |> Path.join("whc-sites.csv")
            |> File.stream!()
            |> CSV.decode!(headers: true, escape_max_lines: 20)
            |> Enum.count()

  @csv_headers [
                "short_description_ar", "unique_number", "name_zh", "C5", "iso_code", "C4",
                "category", "name_ar", "N9", "C1", "short_description_ru", "states_name_en",
                "danger", "area_hectares", "latitude", "name_es", "date_end", "states_name_es",
                "short_description_zh", "transboundary", "name_fr", "date_inscribed", "N10",
                "short_description_en", "N8", "justification_fr", "region_en",
                "category_short", "name_ru", "states_name_ar", "short_description_es",
                "short_description_fr", "longitude", "C3", "secondary_dates", "states_name_fr",
                "criteria_txt", "N7", "rev_bis", "C6", "justification_en", "region_fr",
                "states_name_ru", "states_name_zh", "id_no", "C2", "name_en", "udnp_code",
                "danger_list"
              ]

  @query_params @csv_headers |> Enum.shuffle() |> Enum.take(3) |> Enum.join(",")

  @required_fields [
    "unique_number",
    "id_no",
    "category",
    "date_inscribed",
    "longitude",
    "latitude",
    "area_hectares"
  ]

  @lang [
    "en", "fr", "es", "ru", "ar", "zh"
  ]
  |> Enum.random()

  @lang_fields ["name", "short_description", "states_name"]

  @number 1..@csv_rows |> Enum.random()

  test "GET /api/locations returns parsed CSV file in JSON with all keys and rows" do
    conn =
      conn(:get, "/api/locations")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) |> List.first() |> Map.keys == @csv_headers
    assert Jason.decode!(conn.resp_body) |> Enum.count() == @csv_rows
  end

  test "GET /api/locations?lang=#{@lang}&from=#{@number}&size=#{@number} returns parsed CSV file in JSON with keys filtered by language" do
    conn =
      conn(:get, "/api/locations?lang=#{@lang}&from=#{@number}&size=#{@number}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    all_keys =
      @lang_fields
      |> Enum.map(& "#{&1}_#{@lang}")
      |> Enum.concat(@required_fields)

    assert conn.status == 200
    assert all_keys |> Enum.all?(& &1 in (Jason.decode!(conn.resp_body) |> List.first() |> Map.keys())) == true
    assert Jason.decode!(conn.resp_body) |> Enum.count() == @csv_rows - @number + 1
  end

  test "GET /api/locations?query_params=#{@query_params}&from=#{@number}&size=#{@number} returns parsed CSV file in JSON with keys filtered by query_params" do
    conn =
      conn(:get, "/api/locations?query_params=#{@query_params}&from=#{@number}&size=#{@number}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    all_keys =
      @query_params
      |> String.split(",")
      |> Enum.concat(@required_fields)

    assert conn.status == 200
    assert all_keys |> Enum.all?(& &1 in (Jason.decode!(conn.resp_body) |> List.first() |> Map.keys())) == true
    assert Jason.decode!(conn.resp_body) |> Enum.count() == @csv_rows - @number + 1
  end

  test "GET /api/locations?lang=#{@lang}&query_params=#{@query_params}&from=#{@number}&size=#{@number} returns parsed CSV file in JSON with keys filtered by query_params and lang" do
    conn =
      conn(:get, "/api/locations?lang=#{@lang}&query_params=#{@query_params}&from=#{@number}&size=#{@number}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    all_keys =
      @query_params
      |> String.split(",")
      |> Enum.concat(@required_fields)
      |> Enum.concat(
        @lang_fields
        |> Enum.map(& "#{&1}_#{@lang}")
      )

    assert conn.status == 200
    assert all_keys |> Enum.all?(& &1 in (Jason.decode!(conn.resp_body) |> List.first() |> Map.keys())) == true
    assert Jason.decode!(conn.resp_body) |> Enum.count() == @csv_rows - @number + 1
  end
end
