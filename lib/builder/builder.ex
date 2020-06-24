defmodule Quill.Builder do
  @moduledoc """
  Documentation for Quill.Builder.
  """

  def add_base_fields(data, message, level, timestamp, config) when is_list(message) do
    add_base_fields(data, IO.iodata_to_binary(message), level, timestamp, config)
  end

  def add_base_fields(data, message, level, timestamp, config) do
    data
    |> Map.merge(%{
      name: get_name(config),
      level: level,
      message: message,
      timestamp: get_formatted_timestamp(timestamp),
      version: get_version(config),
    })
  end

  def add_metadata_fields(data, metadata, config) do
    data
    |> Map.merge(metadata
                 |> filter_metadata(config)
                 |> Enum.into(%{})
                 |> Map.delete(:timestamp))
  end



  defp get_name(config) do
    config.name
  end

  defp get_formatted_timestamp({date, {hours, minutes, seconds, microsecond}}) do
    {date, {hours, minutes, seconds}}
    |> NaiveDateTime.from_erl!({microsecond * 1000, 3})
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_iso8601()
  end

  # defp get_level_rank(level) do
  #   case level do
  #     :debug -> 10
  #     :info -> 20
  #     :notice -> 30
  #     :warning -> 40
  #     :error -> 50
  #     :critical -> 60
  #     :alert -> 70
  #     :emergency -> 80
  #   end
  # end

  defp get_version(config) do
    config.version
  end

  defp filter_metadata(metadata, %{metadata: nil}) do
    metadata
  end

  defp filter_metadata(metadata, config) do
    metadata
    |> Enum.filter(fn
      {key, _} -> key in config.metadata
    end)
  end
end
