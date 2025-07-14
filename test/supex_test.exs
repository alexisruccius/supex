defmodule SupexTest do
  use ExUnit.Case, async: true

  alias Supex.Sclang
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
