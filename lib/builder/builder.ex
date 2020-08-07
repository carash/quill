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
      message: message
               |> censor_regex(config.custom_censor_regex)
               |> censor_email(config.email_censor_type)
               |> censor_phone_number(config.phone_number_censor_type, config.phone_number_prefix),
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



  def censor_regex(message, nil) do
    message
  end

  def censor_regex(message, regex_list) when is_list(regex_list) do
    List.foldl(regex_list, message, fn rx, msg -> censor_regex(msg, rx) end)
  end

  def censor_regex(message, regex) do
    Regex.replace(regex, message, "***")
  end

  def censor_email(message, nil) do
    message
  end

  def censor_email(message, :partial) do
    ~r<((?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*"))(@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\]))>
    |> Regex.replace(message, fn _, name, suffix -> "#{String.slice(name, 0..0)}***#{suffix}" end)
  end

  def censor_email(message, :full) do
    ~r<((?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*"))(@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\]))>
    |> Regex.replace(message, fn _, _, _ -> "***" end)
  end

  def censor_phone_number(message, _, nil) do
    message
  end

  def censor_phone_number(message, level, area_code_list) when is_list(area_code_list) do
    List.foldl(area_code_list, message, fn code, msg -> censor_phone_number(msg, level, code) end)
  end

  def censor_phone_number(message, :partial, area_code) do
    "(#{Regex.replace(~r/\+/, area_code, "\\+")})(\\d+)"
    |> Regex.compile!()
    |> Regex.replace(message, fn _, code, number -> "#{code}***#{String.slice(number, -3..-1)}" end)
  end

  def censor_phone_number(message, :full, area_code) do
    "(#{Regex.replace(~r/\+/, area_code, "\\+")})(\\d+)"
    |> Regex.compile!()
    |> Regex.replace(message, fn _, _, _ -> "***" end)
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
