defmodule KeyDiff do
  @moduledoc """
  Provides a single function, `diff/3` for comparing two maps.

  ## Lists

  List diff is not implemented, and lists are treated like any single value of a key.
  If any key value is a list and the list contents change, then this is reflected in the `updates` list
  of the return tuple as a path to the key. The contents of the items in the list are not diffed.

  In order to work around this limitation, it is advised to turn lists into mapped representations -
  especially where the items in the list are maps that can be uniquely identified by one of their keys.

  For example:

      a = %{"key_a" => [%{"id": 1}, %{"id": 2}, %{"id": 3}]}

  should first be transformed into the following map:

      a = %{"key_a" => %{1 => %{"id": 1}, 2 => %{"id": 2}, 3 => %{"id": 3}}}

  This way, `a` can now be used with `diff/3` and it will look for changes in the maps under the `"key_a"` key value.
  """

  @type key :: term()
  @type key_path :: key() | list(key_path())

  @doc """
  Compares two maps/structs and returns a tuple of lists containing differences between the two maps.

  The returning result is a tuple containing 3 lists:

    list of additions - a list of keys new in the map
    list of deletions - a list of keys removed from the previous map
    list of updates - list of keys that had their values modified

  ## Options

    - `depth` _(default: `nil`)_, an integer that will stop the diffing at the specified level of depth
      in the map; it will recurse into the map only `depth` number of times. If not set or `nil` then
      it will process the entire map tree.

  This is useful in quickly determining changes in `depth` number of levels, instead of having the entire
  structure processed.

  ## Examples

      # No differences between the two maps
      iex> KeyDiff.diff(%{a: 1}, %{a: 1})
      {[], [], []}

      # Top-level key is changed.
      iex> KeyDiff.diff(%{a: 1}, %{a: 2})
      {[], [], [:a]}

      # Top level key `:a` is removed and key `:b` is added
      iex> KeyDiff.diff(%{a: 1}, %{b: 2})
      {[:b], [:a], []}

      # Second level key `:b` is removed and second level key `:c` is modified
      # `[:a, [:b]]` represents the top-level key `:a` under which keys `[:b]` are removed
      # from.
      # `[:a, [:c]]` represent the top-level key `:a` under which keys `[:c]` are changed.
      iex> KeyDiff.diff(%{a: %{b: "b", c: "c"}}, %{a: %{c: "d"}})
      {[], [[:a, [:b]]], [[:a, [:c]]]}

  """
  @spec diff(a :: map(), b :: map(), options :: keyword()) ::
          {additions :: list(key_path()), deletions :: list(key_path()),
           updates :: list(key_path())}
  def diff(a, b, opts \\ [])

  def diff(%{} = a, %{} = a, _opts) do
    # Maps are equal, no deletions, no additions
    # and no changes in keys
    {[], [], []}
  end

  def diff(%{} = a, %{} = b, opts) do
    {depth, depth_continue?} =
      case Keyword.get(opts, :depth) do
        nil -> {nil, true}
        0 -> {nil, false}
        n when n > 0 -> {n - 1, true}
        v -> {v, false}
      end

    # Returns {added_keys, deleted_keys, common_keys}
    {added, deleted, common} =
      case {Map.keys(a), Map.keys(b)} do
        {a_keys, a_keys} ->
          # Same keys, but maps are not equal
          # meaning there's changes in the map.
          {[], [], a_keys}

        {a_keys, b_keys} ->
          deleted_keys = a_keys -- b_keys
          added_keys = b_keys -- a_keys
          common_keys = a_keys -- deleted_keys
          {added_keys, deleted_keys, common_keys}
      end

    if depth_continue? do
      # We haven't finished the tree traversal
      # Filter changes in common keys and traverse them in
      # a single pass.
      Enum.reduce(common, {added, deleted, []}, fn key, {added, deleted, changes} = acc ->
        case {Map.get(a, key), Map.get(b, key)} do
          # Underscored same name means _value must have the same value in both places
          {value, value} ->
            # Key has no changes in value. Skip
            acc

          {value_a, value_b} ->
            # Key has different values.
            # Traverse the diff for values
            # path = List.wrap(Keyword.get(opts, :path, [])) ++ [key]

            {rec_added, rec_deleted, rec_changes} =
              diff(
                value_a,
                value_b,
                Keyword.merge(opts, depth: depth)
              )

            changes =
              if rec_changes == [] do
                if changes == [] do
                  [key]
                else
                  changes
                end
              else
                # Prepend key to all rec_changed records
                [[key, rec_changes] | changes]
              end

            n_added =
              case rec_added do
                [] -> added
                list -> [[key, list] | added]
              end

            n_deleted =
              case rec_deleted do
                [] -> deleted
                list -> [[key, list] | deleted]
              end

            {
              n_added,
              n_deleted,
              changes
            }
        end
      end)
    else
      # Finished tree traversal
      # Only filter changes in common keys.
      changes = Enum.reject(common, &(Map.get(a, &1) == Map.get(b, &1)))
      {added, deleted, changes}
    end
  end

  def diff([], [], _opts) do
    {[], [], []}
  end

  def diff(_a, _b, _opts) do
    {[], [], []}
  end
end
