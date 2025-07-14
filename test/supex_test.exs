defmodule SupexTest do
  use ExUnit.Case, async: true

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

  describe "stop/0" do
    test "stops all playing sounds" do
      assert Supex.stop() == :ok
    end
  end
end
