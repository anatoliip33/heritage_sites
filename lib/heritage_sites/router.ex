defmodule HeritageSites.Router do
  use Plug.Router

  alias HeritageSites.FileParser

  @file_path Path.expand("priv/data/", File.cwd!()) |> Path.join("whc-sites.csv")

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/api/locations" do
    from = Integer.parse(conn.params["from"] || "1") |> elem(0) |> Kernel.-(1)
    {size, _} = Integer.parse(conn.params["size"] || "0")

    {status, content} =
      case File.exists?(@file_path) do
        true ->
          {200, FileParser.parse_file(@file_path, conn.params, from, size)}

        _ ->
          {500, %{error: "Failed to read file: the file does not exist"}}
      end

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(content))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
