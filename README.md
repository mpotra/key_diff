# KeyDiff

[![hex.pm version](https://img.shields.io/hexpm/v/key_diff)](https://hex.pm/packages/key_diff)
[![Build Status](https://img.shields.io/github/actions/workflow/status/mpotra/key_diff/elixir.yml
)](https://travis-ci.org/mpotra/key_diff)



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
  iex> KeyDiff.diff(%{a: 1}, %{a: 1})
  {[], [], []}

  iex> KeyDiff.diff(%{a: 1}, %{a: 2})
  {[], [], [:a]}

  iex> KeyDiff.diff(%{a: 1}, %{b: 2})
  {[:b], [:a], []}

  iex> KeyDiff.diff(%{a: %{b: "b", c: "c"}}, %{a: %{c: "d"}})
  {[], [[:a, [:b]]], [[:a, [:c]]]}

  ```

Documentation can be found at <https://hexdocs.pm/key_diff>.
