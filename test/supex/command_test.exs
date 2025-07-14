defmodule Supex.CommandTest do
  use ExUnit.Case, async: true

  alias Supex.Command
  alias Supex.Ugen.SinOsc

  describe "build/1" do
    test "takes a ugen struct like %SinOsc{} and returns a string" do
      assert Command.build(%SinOsc{}) |> is_binary()
    end

    test "takes a ugen struct like `%SinOsc{}` and returns the SuperCollider command" do
      sin_osc = %SinOsc{
        add: 0.6,
        phase: 0.9,
        freq: 269,
        mul: 0.6
      }

      sc_command = "SinOsc.ar(freq: 269, phase: 0.9, mul: 0.6, add: 0.6);"

      assert sin_osc |> Command.build() == sc_command
    end

    test "can be rendered with LFOs inside a Ugen to SuperCollider command" do
      lfo1 = %SinOsc{
        add: 0,
        phase: 0,
        freq: 12,
        mul: 0.1,
        lfo: true
      }

      lfo2 = %SinOsc{
        add: 300,
        phase: 0.3,
        freq: 0.4,
        mul: 269,
        lfo: true
      }

      main_osc = %SinOsc{
        add: 0,
        phase: 0,
        freq: lfo2,
        mul: lfo1,
        lfo: false
      }

      lfo1_command = "SinOsc.kr(freq: 12, phase: 0, mul: 0.1, add: 0);"
      lfo2_command = "SinOsc.kr(freq: 0.4, phase: 0.3, mul: 269, add: 300);"

      main_osc_command =
        "SinOsc.ar(freq: #{lfo2_command}, phase: 0, mul: #{lfo1_command}, add: 0);"

      assert main_osc |> Command.build() == main_osc_command
    end
  end

  describe "play/1" do
    test "wrappes a SuperCollider command in play brackets assign default name 'x'" do
      sc_command = "SinOsc.ar(freq: 12, phase: 0, mul: 0.1, add: 0);"
      result = "x = { SinOsc.ar(freq: 12, phase: 0, mul: 0.1, add: 0); }.play"
      assert Command.play(sc_command) == result
    end
  end

  describe "play/2" do
    test "wrappes a SuperCollider command in play brackets assigns given name" do
      sc_command = "SinOsc.ar(freq: 12, phase: 0, mul: 0.1, add: 0);"
      result = "y = { SinOsc.ar(freq: 12, phase: 0, mul: 0.1, add: 0); }.play"
      assert Command.play(sc_command, "y") == result
    end
  end

  describe "stop/1" do
    test "command for stopping the sound referanced by name" do
      assert Command.stop("y") == "y.free\n"
    end
  end
end
