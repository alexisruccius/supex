defmodule Supex.ExampleTest do
  use ExUnit.Case, async: true

  alias Supex.Command
  alias Supex.Example

  describe "pulse_wave_modulation_with_lfo/0" do
    test "returns example SC command" do
      pulse_wave_example_ugen = %Supex.Ugen.Pulse{
        add: 0,
        freq: %Supex.Ugen.Saw{add: 100, mul: 100, freq: 0.1, lfo: true},
        lfo: false,
        mul: %Supex.Ugen.SinOsc{add: 0.5, phase: 0, mul: 0.4, freq: 2, lfo: true},
        width: %Supex.Ugen.SinOsc{add: 0.5, phase: 0, mul: 0.5, freq: 6, lfo: true}
      }

      assert Example.pulse_wave_modulation_with_lfo() == pulse_wave_example_ugen
    end

    test "can be build to SC command" do
      sc_command_result =
        "Pulse.ar(freq: Saw.kr(freq: 0.1, mul: 100, add: 100);, width: SinOsc.kr(freq: 6, phase: 0, mul: 0.5, add: 0.5);, mul: SinOsc.kr(freq: 2, phase: 0, mul: 0.4, add: 0.5);, add: 0);"

      assert Example.pulse_wave_modulation_with_lfo() |> Command.build() == sc_command_result
    end
  end
end
