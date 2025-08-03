defmodule Supex.Sclang.ScPortTest do
  use ExUnit.Case, async: false

  alias Supex.Sclang.ScPort

  setup_all do
    port = ScPort.open()
    [port: port]
  end

  describe "open/0" do
    test "opens port for sclang" do
      assert ScPort.open() |> is_port()
    end

    test "port started" do
      port = ScPort.open()
      assert port |> Port.info() |> Keyword.get(:name) == ~c"sclang"
    end
  end

  describe "close/1" do
    test "closes the port to sclang" do
      test_port = ScPort.open()
      assert ScPort.close(test_port)
    end
  end

  describe "send_sc_command/2" do
    test "delete all line breaks (except the last one) to prevent chunked command execution on the sclang",
         %{port: port} do
      sc_command = "{\n SinOsc.ar(300, 0, 0.1);\n }.play\n"

      assert ScPort.send_sc_command(sc_command, port) ==
               {port, {:command, "{ SinOsc.ar(300, 0, 0.1); }.play\n"}}
    end

    test "append line break to execute the full command on the sclang", %{port: port} do
      sc_command = "{ SinOsc.ar(300, 0, 0.1); }.play"

      assert ScPort.send_sc_command(sc_command, port) ==
               {port, {:command, "{ SinOsc.ar(300, 0, 0.1); }.play\n"}}
    end
  end
end
