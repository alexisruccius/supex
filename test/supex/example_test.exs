defmodule Supex.ExampleTest do
  use ExUnit.Case

  alias Supex.Example

  describe "pulse_wave_modulation_with_lfo/0" do
    test "returns example synthesizer SC command" do
      pulse_wave_example_ugen = %Supex.Ugen{
        add: 0,
        width: "SinOsc.kr(freq: 6, phase: 0, mul: 0.5, add: 0.5);",
        phase: 0,
        osc: :pulse,
        mul: "SinOsc.kr(freq: 2, phase: 0, mul: 0.4, add: 0.5);",
        freq: "Saw.kr(freq: 0.1, mul: 100, add: 100);",
        lfo: false,
        sc_command:
          "Pulse.ar(freq: Saw.kr(freq: 0.1, mul: 100, add: 100);, width: SinOsc.kr(freq: 6, phase: 0, mul: 0.5, add: 0.5);, mul: SinOsc.kr(freq: 2, phase: 0, mul: 0.4, add: 0.5);, add: 0);",
        sc_name: "x"
      }

      assert Example.pulse_wave_modulation_with_lfo() == pulse_wave_example_ugen
    end
  end
end
