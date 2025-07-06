defmodule Supex.UgenTest do
  use ExUnit.Case, async: true

  doctest Supex.Ugen

  alias Supex.Ugen

  describe "osc/1" do
    test "generic oscillator composing a SINUS wave oscillator" do
      %Ugen{sc_command: sc_command} = Ugen.osc(:sin)
      assert sc_command == "SinOsc.ar(freq: 440, phase: 0, mul: 0.1, add: 0);"
    end

    test "generic oscillator composing a SAW wave oscillator" do
      %Ugen{sc_command: sc_command} = Ugen.osc(:saw)
      assert sc_command == "Saw.ar(freq: 440, mul: 0.1, add: 0);"
    end

    test "generic oscillator composing a PULSE (Square) wave oscillator" do
      %Ugen{sc_command: sc_command} = Ugen.osc(:pulse)
      assert sc_command == "Pulse.ar(freq: 440, width: 0.5, mul: 0.1, add: 0);"
    end
  end

  describe "oscillator composing" do
    test "osc/1" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      %Ugen{sc_command: sc_command} = Ugen.osc(ugen)
      assert sc_command == "SinOsc.ar(freq: 550, phase: 4, mul: 0.2, add: 0.3);"
    end

    test "freq/1" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      %Ugen{sc_command: sc_command} = Ugen.osc(ugen) |> Ugen.freq(690)
      assert sc_command == "SinOsc.ar(freq: 690, phase: 4, mul: 0.2, add: 0.3);"
    end

    test "phase/1" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      %Ugen{sc_command: sc_command} = Ugen.osc(ugen) |> Ugen.phase(2)
      assert sc_command == "SinOsc.ar(freq: 550, phase: 2, mul: 0.2, add: 0.3);"
    end

    test "mul/1" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.3}
      %Ugen{sc_command: sc_command} = Ugen.osc(ugen) |> Ugen.mul(0.4)
      assert sc_command == "SinOsc.ar(freq: 550, phase: 4, mul: 0.4, add: 0.3);"
    end

    test "add/1" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.6}
      %Ugen{sc_command: sc_command} = Ugen.osc(ugen) |> Ugen.add(0.6)
      assert sc_command == "SinOsc.ar(freq: 550, phase: 4, mul: 0.2, add: 0.6);"
    end

    test "name/1" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.6}
      %Ugen{sc_name: sc_name} = Ugen.osc(ugen) |> Ugen.name("x")
      assert sc_name == "x"
    end

    test "all composing" do
      %Ugen{sc_command: sc_command} =
        Ugen.osc() |> Ugen.freq(690) |> Ugen.phase(6) |> Ugen.mul(0.9) |> Ugen.add(0.69)

      assert sc_command == "SinOsc.ar(freq: 690, phase: 6, mul: 0.9, add: 0.69);"
    end
  end

  describe "lfo/1" do
    test "transform a oscillator to a LFO" do
      ugen = %Ugen{
        osc: :sin,
        freq: 4,
        phase: 0,
        mul: 0.2,
        add: 0.4,
        lfo: false
      }

      %Ugen{sc_command: sc_command} = ugen |> Ugen.lfo()
      assert sc_command == "SinOsc.kr(freq: 4, phase: 0, mul: 0.2, add: 0.4);"
    end

    test "transform a SAW oscillator to a LFO" do
      ugen = %Ugen{
        osc: :saw,
        freq: 5,
        mul: 0.1,
        add: 0,
        lfo: false
      }

      %Ugen{sc_command: sc_command} = ugen |> Ugen.lfo()
      assert sc_command == "Saw.kr(freq: 5, mul: 0.1, add: 0);"
    end
  end

  describe "play/1" do
    test "add play and name to oscillator command from %Ugen{}" do
      ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.3, sc_name: "y"}
      sc_command = ugen |> Ugen.osc() |> Ugen.play()
      assert sc_command == "y = { SinOsc.ar(freq: 550, phase: 4, mul: 0.2, add: 0.3); }.play"
    end

    test "add play and name to raw command string" do
      cmd_without = "RLPF.ar(Pulse.ar([100, 250], 0.5, 0.1), XLine.kr(8000, 400, 5), 0.05)"

      cmd_name_play =
        "x = { RLPF.ar(Pulse.ar([100, 250], 0.5, 0.1), XLine.kr(8000, 400, 5), 0.05) }.play"

      assert cmd_without |> Ugen.play() == cmd_name_play
    end
  end

  test "stop sine oscillator command" do
    ugen = %Ugen{freq: 550, phase: 4, mul: 0.2, add: 0.3, sc_name: "y"}
    sc_command = ugen |> Ugen.osc() |> Ugen.stop()
    assert sc_command == "y.free\n"
  end
end
