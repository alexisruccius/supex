defmodule SupexTest do
  use ExUnit.Case, async: true, group: :sclang_tests

  doctest Supex

  import Mox

  alias Supex.Sclang
  alias Supex.Ugen.Pan2
  alias Supex.Ugen.Pulse
  alias Supex.Ugen.Saw
  alias Supex.Ugen.SinOsc

  # Mox: make sure mocks are verified when the test exits
  setup :verify_on_exit!

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

  describe "sin/0" do
    test "returns a %SinOsc{} sin oscillator" do
      assert %SinOsc{add: 0, phase: 0, freq: 440, mul: 0.1, lfo: false} = Supex.sin()
    end
  end

  describe "saw/0" do
    test "returns a %Saw{} saw oscillator" do
      assert %Saw{add: 0, freq: 440, mul: 0.1, lfo: false} = Supex.saw()
    end
  end

  describe "pulse/0" do
    test "returns a %Pulse{} pulse oscillator" do
      assert %Pulse{add: 0, freq: 440, mul: 0.2, lfo: false, width: 0.5} = Supex.pulse()
    end
  end

  describe "lfo/1" do
    test "sets the LFO to true" do
      ugen = %SinOsc{
        freq: 4,
        phase: 0,
        mul: 0.2,
        add: 0.4,
        lfo: false
      }

      assert %SinOsc{lfo: true} = ugen |> Supex.lfo()
    end
  end

  describe "freq/2" do
    test "sets the frequency of an oscillator" do
      ugen = %Saw{freq: 4, mul: 0.3, add: 0.4, lfo: false}
      result = %Saw{freq: 69, mul: 0.3, add: 0.4, lfo: false}

      assert ugen |> Supex.freq(69) == result
    end
  end

  describe "phase/2" do
    test "sets the phase of a sin oscillator" do
      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      result = %SinOsc{freq: 4, phase: 0.6, mul: 0.2, add: 0.4, lfo: false}

      assert ugen |> Supex.phase(0.6) == result
    end
  end

  describe "width/2" do
    test "sets the width of a pulse oscillator" do
      ugen = %Pulse{freq: 69, width: 0.3, mul: 0.3, add: 0.4, lfo: false}
      result = %Pulse{freq: 69, width: 0.6, mul: 0.3, add: 0.4, lfo: false}

      assert ugen |> Supex.width(0.6) == result
    end
  end

  describe "mul/2" do
    test "sets the mul of an oscillator" do
      ugen = %Pulse{freq: 69, width: 0.6, mul: 0.1, add: 0.4, lfo: false}
      result = %Pulse{freq: 69, width: 0.6, mul: 0.6, add: 0.4, lfo: false}

      assert ugen |> Supex.mul(0.6) == result
    end
  end

  describe "add/2" do
    test "sets the add of an oscillator" do
      ugen = %Pulse{freq: 69, width: 0.6, mul: 0.1, add: 0.4, lfo: false}
      result = %Pulse{freq: 69, width: 0.6, mul: 0.1, add: 0.1, lfo: false}

      assert ugen |> Supex.add(0.1) == result
    end
  end

  describe "pos/2" do
    test "sets the position for the %Pan2{}" do
      ugen = %Pan2{in: "SinOsc.ar(440)", pos: 0, level: 1}
      result = %Pan2{in: "SinOsc.ar(440)", pos: 0.69, level: 1}

      assert ugen |> Supex.pos(0.69) == result
    end
  end

  describe "level/2" do
    test "sets the level for the %Pan2{}" do
      ugen = %Pan2{in: "SinOsc.ar(440)", pos: 0, level: 1}
      result = %Pan2{in: "SinOsc.ar(440)", pos: 0, level: 0.69}

      assert ugen |> Supex.level(0.69) == result
    end
  end

  describe "pan/1" do
    test "wrappes a ugen, like a %SinOsc{} struct, as input in %Pan2{} struct" do
      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}

      result = %Pan2{
        in: %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false},
        pos: 0,
        level: 1
      }

      assert ugen |> Supex.pan() == result
    end
  end

  describe "play/1" do
    setup :port_mock

    test "returns a %Sclang{} struct" do
      {:ok, _pid} = start_supervised(Sclang)

      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      assert %Sclang{} = Supex.play(ugen)
    end
  end

  describe "play/2" do
    setup :port_mock

    test "returns a %Sclang{} struct with name in the executed command" do
      {:ok, _pid} = start_supervised(Sclang)

      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      assert %Sclang{last_command_executed: command} = Supex.play(ugen, "z")
      assert command =~ "z = "
    end
  end

  describe "stop/0" do
    setup :port_mock

    test "stops all playing sounds" do
      {:ok, _pid} = start_supervised(Sclang)

      assert %Sclang{} = Supex.stop()
    end
  end
end
