defmodule Supex.Sclang.ScPortTest do
  use ExUnit.Case, async: true

  import Mox

  alias Supex.Sclang.ScPort

  # Mox: make sure mocks are verified when the test exits
  setup :verify_on_exit!
  setup :port_mock

  defp port_mock(_context) do
    # Mox
    Supex.Sclang.ScPortMock
    |> expect(:open, fn _name, _opts -> Port.open({:spawn, "cat"}, [:binary]) end)

    :ok
  end

  describe "open/0" do
    test "opens port for sclang" do
      assert ScPort.open() |> is_port()
    end

    test "port started" do
      port = ScPort.open()
      assert port |> Port.info() |> Keyword.get(:name) == ~c"cat"
    end
  end

  describe "close/1" do
    test "closes the port to sclang" do
      port = ScPort.open()
      assert ScPort.close(port)
    end
  end

  describe "send_sc_command/2" do
    test "delete all line breaks (except the last one) to prevent chunked command execution on the sclang" do
      port = ScPort.open()
      sc_command = "{\n SinOsc.ar(300, 0, 0.1);\n }.play\n"

      assert ScPort.send_sc_command(sc_command, port) ==
               {port, {:command, "{ SinOsc.ar(300, 0, 0.1); }.play\n"}}

      assert_receive {^port, {:data, "{ SinOsc.ar(300, 0, 0.1); }.play\n"}}
    end

    test "append line break to execute the full command on the sclang" do
      port = ScPort.open()
      sc_command = "{ SinOsc.ar(300, 0, 0.1); }.play"

      assert ScPort.send_sc_command(sc_command, port) ==
               {port, {:command, "{ SinOsc.ar(300, 0, 0.1); }.play\n"}}

      assert_receive {^port, {:data, "{ SinOsc.ar(300, 0, 0.1); }.play\n"}}
    end
  end
end
