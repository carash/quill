defmodule Quill do
  @moduledoc """
  Documentation for Quill.
  """

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

  def handle_event({_level, _, {Logger, _message, _timestamp, _metadata}}, state) do
    # TODO output log
    {:ok, state}
  end



  defp configure(options, state) do
    state
    |> Map.merge(Enum.into(options, %{}))
  end

  defp default_state do
    %{
      level: :debug,
      io_device: :stdio,
      metadata: nil,
    }
  end
end
