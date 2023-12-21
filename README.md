# KeyDiff

[![hex.pm version](https://img.shields.io/hexpm/v/key_diff)](https://hex.pm/packages/key_diff)
[![Build Status](https://img.shields.io/github/actions/workflow/status/mpotra/key_diff/elixir.yml
)](https://travis-ci.org/mpotra/key_diff)

KeyDiff is an Elixir library that compares two maps/structs and returns a tuple of lists containing 
differences between the two maps.

The returning result is a tuple containing 3 lists:
- list of additions - a list of keys new in the map
- list of deletions - a list of keys removed from the previous map
- list of updates - list of keys that had their values modified

Each list entry is either a key or a list of keys in the subtree.

Keys from the top level tree are single-term items in the list.
For changes in the subtree, each item is a list `[K, [K(n-1), ...]]`` where the first
item is the top level key and the second item is a list of keys changed in the next level.

The general rule is that if the `value` of a `key` is added, removed or updated, the `key` is returned as
a single list item. However, if the `value` of a `key` is also a map where any changes occur, then
the `key` is never present as a single item in the list, but a list representing the path to the changes.
The fact that there are changes inside the map `value` of a `key` automatically implies that the `value` of 
`key` has also changed.

Note: additions or deletions in a child map will not include the parent `key` in the `updates` list of
the result.

This format is used in all three lists returned in the tuple result.

## Installation

```elixir
def deps do
  [
    {:key_diff, "~> 0.1.0"}
  ]
end
```

## Examples

  ```elixir
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

  ```

## Options

`KeyDiff.diff/2` supports the `depth` option, that will stop the diffing at the specified level of depth
in the map; it will recurse into the map only `depth` number of times.

This is useful in quickly determining changes in `depth` number of levels, instead of having the entire
structure processed.

## Lists

List diff is not implemented, and lists are treated like any single value of a key.
If any key value is a list and the list contents change, then this is reflected in the `updates` list
of the return tuple as a path to the key. The contents of the items in the list are not diffed.

In order to work around this limitation, it is advised to turn lists into mapped representations - 
especially where the items in the list are maps that can be uniquely identified by one of their keys.

For example:

```elixir
  a = %{"key_a" => [%{"id": 1}, %{"id": 2}, %{"id": 3}]}
```

should first be transformed into the following map:

```elixir
  a = %{"key_a" => %{"1" => %{"id": 1}, "2" => %{"id": 2}}}
```

This way, `a` can now be used with `KeyDiff.diff/2` and it will look for changes in the maps under the `"key_a"` key value.

## Benchmarks and performance

Benmarking `key_diff` with `json_diff`, `map_diff` and `json_diff_ex` on large maps, 
showed that `key_diff` is 2-3x times faster than the other libraries.
The benchmarks were done with `depth: nil` (default) meaning the entire tree was walked.

## Documentation

Documentation can be found at <https://hexdocs.pm/key_diff>.
