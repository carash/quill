defmodule Quill.EncoderTest do
  use ExUnit.Case

  test "able to encode normal metadata" do
    assert "level=error message=\"random test\"" ==
             Quill.Encoder.encode(
               %{
                 level: :error,
                 message: "random test"
               },
               %{log_format: :logfmt, priority_fields: [:level]}
             )
  end

  test "able to encode struct metadata" do
    assert is_binary(
             Quill.Encoder.encode(
               %{
                 level: :error,
                 message: "random test",
                 conn: %ConnMock{}
               },
               %{log_format: :logfmt, priority_fields: [:level]}
             )
           )
  end

  test "able to encode exception metadata" do
    assert is_binary(
             Quill.Encoder.encode(
               %{
                 level: :error,
                 message: "random test",
                 crash_reason:
                   {%UndefinedFunctionError{
                      arity: 0,
                      function: :undefined,
                      message: nil,
                      module: nil,
                      reason: nil
                    },
                    [
                      {nil, :undefined, [], []},
                      {EventServiceWeb.HealthController, :health, 2,
                       [file: 'lib/event_service_web/controllers/health_controller.ex', line: 18]},
                      {EventServiceWeb.HealthController, :action, 2,
                       [file: 'lib/event_service_web/controllers/health_controller.ex', line: 1]},
                      {EventServiceWeb.HealthController, :phoenix_controller_pipeline, 2,
                       [file: 'lib/event_service_web/controllers/health_controller.ex', line: 1]},
                      {Phoenix.Router, :__call__, 2, [file: 'lib/phoenix/router.ex', line: 355]}
                    ]}
               },
               %{log_format: :logfmt, priority_fields: [:level]}
             )
           )
  end
end
