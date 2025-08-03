defmodule Supex.SclangTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Supex.Sclang

  describe "error messaging" do
    test "when Sclang server not started" do
      sc_command = "{ SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0); }.play"
      {result, log} = with_log(fn -> Sclang.execute(sc_command) end)

      assert result == :ok
      assert log =~ "Sclang Server not started!"
    end

    test "when Sclang server is booting, but not started yet" do
      {:ok, _pid} = start_supervised(Sclang)
      sc_command = "{ SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0); }.play"
      {result, log} = with_log(fn -> Sclang.execute(sc_command) end)

      assert %Supex.Sclang{port: _port, sc_server_booted: false} = result
      assert log =~ "Sclang Server is booting, but not started yet!"
    end
  end

  describe "start_link/1" do
    test "Sclang GenServer started" do
      {:ok, _pid} = start_supervised(Sclang)
    end

    test "Sclang GenServer state ok" do
      start_supervised!(Sclang)
      assert %Sclang{} = :sys.get_state(Sclang)
    end

    test "Sclang GenServer has sclang port started" do
      start_supervised!(Sclang)
      assert %Sclang{port: port} = :sys.get_state(Sclang)
      assert is_port(port)
    end
  end

  describe "SC server booted" do
    test "successfully and executes command" do
      {:ok, _pid} = start_supervised(Sclang)
      # wait for sc server to boot
      Process.sleep(4000)

      assert %Sclang{sc_server_booted: true} = :sys.get_state(Sclang)

      sc_command = "{ SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0); }.play"
      result = Sclang.execute(sc_command)

      assert %Sclang{port: _port, sc_server_booted: true} = result
    end
  end

  describe "SC server not booted" do
    test "if port is closed" do
      {:ok, _pid} = start_supervised(Sclang)
      # wait for sc server to boot
      Process.sleep(4000)

      Sclang.close_port()

      assert %Sclang{sc_server_booted: false} = :sys.get_state(Sclang)
    end
  end

  describe "stop_playing/0" do
    test "stops all sounds" do
      {:ok, _pid} = start_supervised(Sclang)
      # wait for sc server to boot
      Process.sleep(4000)

      assert %Sclang{
               port: _port,
               sc_server_booted: true,
               last_command_executed: "s.freeAll\n"
             } = Sclang.stop_playing()
    end
  end

  describe "handle_info/2" do
    test "handle >server booted< message from port" do
      port = "test"
      data = "SuperCollider 3 server ready.\n"
      state = %Sclang{}
      assert {:noreply, _new_state} = Sclang.handle_info({port, {:data, data}}, state)
    end

    test "handle other >server booted< message from port" do
      port = "test"
      data = "Shared memory server interface initialized"
      state = %Sclang{}
      assert {:noreply, _new_state} = Sclang.handle_info({port, {:data, data}}, state)
    end

    test "handle >stop playing a sound< message from port" do
      port = "test"
      data = "s.freeAll\n"
      state = %Sclang{}
      assert {:noreply, _new_state} = Sclang.handle_info({port, {:data, data}}, state)
    end

    test "handle other message from port" do
      port = "test"
      data = "random message.\n"
      state = %Sclang{}
      assert {:noreply, _new_state} = Sclang.handle_info({port, {:data, data}}, state)
    end
  end
end
