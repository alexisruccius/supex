defmodule SupexTest do
  use ExUnit.Case, async: true

  alias Supex.Sclang
  alias Supex.Ugen.Pan2
  alias Supex.Ugen.SinOsc

  describe "osc/0" do
    test "returns a %SinOsc sin oscillator" do
      assert %SinOsc{add: 0, phase: 0, freq: 440, mul: 0.1, lfo: false} = Supex.sin()
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

  describe "phase/2" do
    test "gets the oscillator as an LFO SuperCollider's command" do
      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      result = %SinOsc{freq: 4, phase: 0.6, mul: 0.2, add: 0.4, lfo: false}

      assert ugen |> Supex.phase(0.6) == result
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
    test "returns a %Sclang{} struct" do
      {:ok, _pid} = start_supervised(Sclang)
      # wait for sc server to boot
      Process.sleep(4000)

      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      assert %Sclang{} = Supex.play(ugen)
    end
  end

  describe "play/2" do
    test "returns a %Sclang{} struct with name in the executed command" do
      {:ok, _pid} = start_supervised(Sclang)
      # wait for sc server to boot
      Process.sleep(4000)

      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      assert %Sclang{last_command_executed: command} = Supex.play(ugen, "z")
      assert command =~ "z = "
    end
  end

  describe "stop/0" do
    test "stops all playing sounds" do
      {:ok, _pid} = start_supervised(Sclang)
      # wait for sc server to boot
      Process.sleep(4000)

      assert %Sclang{} = Supex.stop()
    end
  end
end
