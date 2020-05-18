defmodule Quill.Encoder do
  @moduledoc """
  Documentation for Quill.Encoder.
  """

  def encode(map) do
    map
    |> force_map()
    |> Jason.encode!()
  end

  defp force_map(value) when is_map(value) do
    Enum.into(value, %{}, 
              fn {k, v} -> {force_map(k), force_map(v)} end)
  end

  defp force_map(value) when is_list(value) do
    Enum.map(value, &force_map/1)
  end

  defp force_map(%{__struct__: _} = value) do
    value
    |> Map.from_struct()
    |> force_map()
  end

  defp force_map(value) when is_pid(value) or
                                is_port(value) or
                                is_reference(value) or
                                is_tuple(value) or
                                is_function(value), do: inspect(value)

  defp force_map(value), do: value
end
