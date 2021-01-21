defmodule Quill.Encoder do
  @moduledoc """
  Documentation for Quill.Encoder.
  """

  # Encode output as Logfmt
  def encode(map, config = %{log_format: :logfmt}) do
    map
    |> force_map()
    |> ordered_keywords(config)
    |> Logfmt.encode()
  end

  # Encode output as JSON
  def encode(map, %{log_format: :json}) do
    map
    |> force_map()
    |> Jason.encode!()
  end

  # Encode output as default (JSON)
  def encode(map, _) do
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

  defp force_map(value) when is_pid(value)
                        when is_port(value)
                        when is_reference(value)
                        when is_tuple(value)
                        when is_function(value), do: inspect(value)

  defp force_map(value), do: value

  defp ordered_keywords(value, %{priority_fields: fields}) do
    []
    |> Keyword.merge(Enum.into(fields, [],
                               fn f -> {f, value[f]} end))
    |> Keyword.merge(Enum.into(Map.drop(value, fields), [],
                               fn {k, v} -> {k, v} end))
  end

  defp ordered_keywords(value, _) do
    Enum.into(value, [],
              fn {k, v} -> {k, v} end)
  end
end
