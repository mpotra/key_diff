
# Helper function to turn lists into maps.
reduce_by_id = fn list, id_key ->
  list
  |> Enum.reduce(%{}, fn item, acc ->
    id = Map.get(item, id_key)
    Map.put(acc, id, Map.delete(item, id_key))
  end)
end

data =
  [
    "vatsim-data1.json",
    "vatsim-data2.json",
    "vatsim-data3.json"
  ]
  |> Enum.map(fn filename -> Path.expand("./bench_data/#{filename}", __DIR__) end)
  |> Enum.map(fn filename -> File.read!(filename) end)
  |> Enum.map(fn data -> Jason.decode!(data) end)
  |> Enum.map(fn json ->
    Enum.reduce(json, %{}, fn {key, value}, acc ->
      cond do
        key == "general" ->
          Map.put(acc, key, value)

        Enum.member?(["pilots", "controllers", "atis", "prefiles"], key) ->
          Map.put(acc, key, reduce_by_id.(value, "cid"))

        Enum.member?(["facilities", "ratings", "pilot_ratings", "military_ratings"], key) ->
          Map.put(acc, key, reduce_by_id.(value, "id"))

        true ->
          acc
      end
    end)
  end)

inputs = %{
  "(1) no changes" => {Enum.at(data, 0), Enum.at(data, 0)},
  "(2) minimal changes" => {Enum.at(data, 0), Enum.at(data, 1)},
  "(3) maximum changes" => {Enum.at(data, 0), Enum.at(data, 2)}
}

Benchee.run(
  %{
    "map_diff" => fn {a, b} -> MapDiff.diff(a, b) end,
    "json_diff_ex" => fn {a, b} -> JsonDiffEx.diff(a, b) end,
    "json_diff" => fn {a, b} -> JSONDiff.diff(a, b) end,
    "key_diff" => fn {a, b} -> KeyDiff.diff(a, b) end
  },
  inputs: inputs
)
