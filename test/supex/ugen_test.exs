defmodule Supex.UgenTest do
  use ExUnit.Case, async: true

  doctest Supex.Ugen

  alias Supex.Ugen
  alias Supex.Ugen.Pan2
  alias Supex.Ugen.Pulse
  alias Supex.Ugen.Saw
  alias Supex.Ugen.SinOsc

  describe "osc/1" do
    test "generic oscillator composing a SINUS wave oscillator" do
      ugen = %SinOsc{freq: 440, phase: 0, mul: 0.1, add: 0}
      assert ugen == Ugen.sin()
    end

    test "generic oscillator composing a SAW wave oscillator" do
      ugen = %Saw{freq: 440, mul: 0.1, add: 0}
      assert ugen == Ugen.saw()
    end

    test "generic oscillator composing a PULSE (Square) wave oscillator" do
      ugen = %Pulse{freq: 440, width: 0.5, mul: 0.2, add: 0}
      assert ugen == Ugen.pulse()
    end
  end

  describe "oscillator composing" do
    test "osc/1" do
      ugen = %SinOsc{freq: 440, phase: 0, mul: 0.1, add: 0}
      assert ugen == Ugen.sin()
    end

    test "freq/1" do
      ugen = %SinOsc{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      result = %SinOsc{freq: 690, phase: 4, mul: 0.2, add: 0.3}
      assert ugen |> Ugen.freq(690) == result
    end

    test "phase/1" do
      ugen = %SinOsc{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      result = %SinOsc{freq: 550, phase: 2, mul: 0.2, add: 0.3}
      assert ugen |> Ugen.phase(2) == result
    end

    test "mul/1" do
      ugen = %SinOsc{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      result = %SinOsc{freq: 550, phase: 4, mul: 2, add: 0.3}
      assert ugen |> Ugen.mul(2) == result
    end

    test "add/1" do
      ugen = %SinOsc{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      result = %SinOsc{freq: 550, phase: 4, mul: 0.2, add: 0.6}
      assert ugen |> Ugen.add(0.6) == result
    end

    test "all composing" do
      ugen = Ugen.sin() |> Ugen.freq(690) |> Ugen.phase(6) |> Ugen.mul(0.9) |> Ugen.add(0.69)
      result = %SinOsc{freq: 690, phase: 6, mul: 0.9, add: 0.69}
      assert ugen == result
    end
  end

  describe "lfo/1" do
    test "set LFO true for a sine oscillator" do
      ugen = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: false}
      result = %SinOsc{freq: 4, phase: 0, mul: 0.2, add: 0.4, lfo: true}
      assert ugen |> Ugen.lfo() == result
    end

    test "set LFO true for a Saw oscillator" do
      ugen = %Saw{freq: 5, mul: 0.1, add: 0, lfo: false}
      result = %Saw{freq: 5, mul: 0.1, add: 0, lfo: true}
      assert ugen |> Ugen.lfo() == result
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

      assert ugen |> Ugen.pan() == result
    end
  end
end
