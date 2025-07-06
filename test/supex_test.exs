defmodule SupexTest do
  use ExUnit.Case

  alias Supex.Ugen

  describe "osc/0" do
    test "returns a %Ugen sin oscillator" do
      assert %Supex.Ugen{
               add: 0,
               width: 0.5,
               phase: 0,
               sc_command: "SinOsc.ar(freq: 440, phase: 0, mul: 0.1, add: 0);",
               osc: :sin,
               freq: 440,
               mul: 0.1,
               sc_name: "x",
               lfo: false
             } = Supex.osc()
    end
  end

  describe "lfo/1" do
    test "transforms the oscillator to an LFO SuperCollider's command" do
      ugen = %Ugen{
        osc: :sin,
        freq: 4,
        phase: 0,
        mul: 0.2,
        add: 0.4,
        lfo: false
      }

      assert ugen |> Supex.lfo() == "SinOsc.kr(freq: 4, phase: 0, mul: 0.2, add: 0.4);"
    end
  end

  describe "phase/2" do
    test "gets the oscillator as an LFO SuperCollider's command" do
      ugen = %Ugen{
        osc: :sin,
        freq: 4,
        phase: 0,
        mul: 0.2,
        add: 0.4,
        lfo: false
      }

      ugen_with_phase = ugen |> Supex.phase(0.6)

      assert ugen_with_phase.sc_command == "SinOsc.ar(freq: 4, phase: 0.6, mul: 0.2, add: 0.4);"
    end
  end

  describe "name/2" do
    test "gets the oscillator as an LFO SuperCollider's command" do
      ugen = %Ugen{
        osc: :sin,
        freq: 4,
        phase: 0,
        mul: 0.2,
        add: 0.4,
        lfo: false
      }

      ugen_with_name = ugen |> Supex.name("z")

      assert ugen_with_name.sc_name == "z"
    end
  end
end
