defmodule KeyDiff do
  @moduledoc """
  Documentation for `KeyDiff`.
  """

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
          {_value, _value} ->
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
