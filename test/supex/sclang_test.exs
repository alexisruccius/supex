defmodule Supex.SclangTest do
  use ExUnit.Case, async: true, group: :sclang_tests

  import ExUnit.CaptureLog
  import Mox

  alias Supex.Sclang

  # Mox: make sure mocks are verified when the test exits
  setup :verify_on_exit!
  setup :port_mock

  defp port_mock(_context) do
    # Mox
    Sclang.ScPortMock
    |> expect(:open, fn _name, _opts -> Port.open({:spawn, "cat"}, [:binary]) end)

    # Mox allowance definition
    # its function is envoked later when the mock is used
    Sclang.ScPortMock
    |> allow(self(), fn -> GenServer.whereis(Sclang) end)

    :ok
  end

  describe "error messaging" do
    test "when Sclang server not started" do
      # make sure Sclang GenServer is stopped
      assert {:ok, _pid} = start_supervised(Sclang)
      GenServer.stop(Sclang)

      sc_command = "{ SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0); }.play"
      {result, log} = with_log(fn -> Sclang.execute(sc_command) end)

      assert result == :ok
      assert log =~ "Sclang Server not started!"
    end

    test "when Sclang server is booting, but not started yet" do
      {:ok, _pid} = start_supervised(Sclang)
      sc_command = "{ SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0); }.play"
      {result, log} = with_log(fn -> Sclang.execute(sc_command) end)

      assert %Sclang{port: _port, sc_server_booted: false} = result
      assert log =~ "Sclang Server is booting, but not started yet!"
    end
  end

  describe "start_link/1" do
    test "Sclang GenServer started with SC command for booting" do
      assert {:ok, pid} = start_supervised(Sclang)
      :erlang.trace(pid, true, [:receive])
      assert_receive {:trace, ^pid, :receive, {_port, {:data, data}}}, 10
      assert data == "s.boot\n"
    end

    test "Sclang GenServer state ok" do
      assert {:ok, _pid} = start_supervised(Sclang)
      assert %Sclang{} = :sys.get_state(Sclang)
    end

    test "Sclang GenServer has sclang port started" do
      assert {:ok, _pid} = start_supervised(Sclang)
      assert %Sclang{port: port} = :sys.get_state(Sclang)
      assert is_port(port)
    end
  end

  describe "SC server booted" do
    test "successfully and executes command" do
      {:ok, _pid} = start_supervised(Sclang)

      # wait for sc server to boot
      Process.sleep(2)
      # send booted message for testing with `cat`
      Sclang.execute("SuperCollider 3 server ready.")
      # wait for Sclang and ScPort
      Process.sleep(1)
      assert %Sclang{sc_server_booted: true} = :sys.get_state(Sclang)

      sc_command = "{ SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0); }.play"
      result = Sclang.execute(sc_command)

      assert %Sclang{
               port: _port,
               last_command_executed: last_command_executed,
               sc_server_booted: true
             } =
               result

      assert sc_command <> "\n" == last_command_executed
    end
  end

  describe "SC server not booted" do
    test "if port is closed" do
      {:ok, _pid} = start_supervised(Sclang)

      # wait for sc server to boot
      Process.sleep(2)
      # send booted message for testing with `cat`
      Sclang.execute("SuperCollider 3 server ready.")
      # wait for Sclang and ScPort
      Process.sleep(1)
      assert %Sclang{sc_server_booted: true} = :sys.get_state(Sclang)

      Sclang.close_port()
      assert %Sclang{sc_server_booted: false} = :sys.get_state(Sclang)
    end
  end

  describe "stop_playing/0" do
    test "stops all sounds" do
      {:ok, _pid} = start_supervised(Sclang)

      # wait for sc server to boot
      Process.sleep(2)
      # send booted message for testing with `cat`
      Sclang.execute("SuperCollider 3 server ready.")
      # wait for Sclang and ScPort
      Process.sleep(1)

      assert %Sclang{
               port: _port,
               sc_server_booted: true,
               last_command_executed: "s.freeAll\n"
             } = Sclang.stop_playing()
    end
  end

  describe "handle_info/2" do
    setup :start_server_with_trace

    defp start_server_with_trace(_context) do
      {:ok, pid} = start_supervised(Sclang)
      :erlang.trace(pid, true, [:receive])
      # receive SC boot command message
      assert_receive {:trace, ^pid, :receive, {_port, {:data, "s.boot\n"}}}, 20
      %{pid: pid}
    end

    defp assert_sclang_receive(data, pid) do
      Sclang.execute(data)
      assert_receive {:trace, ^pid, :receive, {_port, {:data, data_received}}}, 10
      assert data_received == data <> "\n"
    end

    test "handle >server booted< message from port", %{pid: pid} do
      data = "SuperCollider 3 server ready."
      assert_sclang_receive(data, pid)
    end

    test "handle other >server booted< message from port", %{pid: pid} do
      data = "Shared memory server interface initialized"
      assert_sclang_receive(data, pid)
    end

    test "handle >stop playing a sound< message from port", %{pid: pid} do
      data = "s.freeAll"
      assert_sclang_receive(data, pid)
    end

    test "handle other message from port", %{pid: pid} do
      data = "random message."
      assert_sclang_receive(data, pid)
    end
  end
end
