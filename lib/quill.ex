defmodule Quill do
  @moduledoc """
  Documentation for Quill.
  """

  @behaviour :gen_event

  def init(__MODULE__) do
    # TODO create state from options
    {:ok, %{}}
  end

  def handle_call({:configure, _options}, state) do
    # TODO update state with options
    {:ok, :ok, state}
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
end
