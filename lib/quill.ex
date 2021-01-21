defmodule Quill do
  @moduledoc Quill.MixProject.project()[:description]

  alias Quill.{Builder, Encoder}

  @behaviour :gen_event

  def init(__MODULE__) do
    {:ok, configure(Application.get_env(:logger, Quill, []), default_state())}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_info(_msg, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def code_change(_old, state, _extra) do
    {:ok, state}
  end



  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({_, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _, {Logger, message, timestamp, metadata}}, state = %{level: min_level}) do
    if level_priority(level) >= level_priority(min_level) do
      try do
        %{}
        |> Builder.add_base_fields(message, level, timestamp, state)
        |> Builder.add_metadata_fields(metadata, state)
        |> Encoder.encode(state)
        |> output_log(state)
      rescue
        e -> output_error(e, state)
      end
    end
    {:ok, state}
  end



  defp level_priority(:trace), do: 0
  defp level_priority(:debug), do: 10
  defp level_priority(:info), do: 20
  defp level_priority(:notice), do: 30
  defp level_priority(:warn), do: 40
  defp level_priority(:warning), do: 40
  defp level_priority(:error), do: 50
  defp level_priority(:critical), do: 60
  defp level_priority(:alert), do: 70
  defp level_priority(:emergency), do: 80
  defp level_priority(_), do: -10

  defp configure(options, state) do
    state
    |> Map.merge(Enum.into(options, %{}))
  end

  defp default_state do
    %{
      name: "app",
      level: :info,
      io_device: :stdio,
      priority_fields: [], # Use atoms as prioritized field names
      log_format: :json, # Valid values are :json or :logfmt
      log_error: true,
      metadata: nil,
      version: 0,
      custom_censor_regex: nil,
      email_censor_type: nil,
      phone_number_censor_type: nil,
      phone_number_prefix: [],
    }
  end

  defp output_log(msg, config) do
    IO.puts(config.io_device, msg)
  end

  defp output_error(e, config) do
    case config.log_error do
      true -> IO.puts(config.io_device, inspect(e))
      _ -> :ok
    end
  end
end
