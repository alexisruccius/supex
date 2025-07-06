defmodule Supex.Sclang.PanTest do
  use ExUnit.Case

  alias Supex.Pan
  alias Supex.Ugen

  describe "center/0" do
    test "for raw SuperCollider's command default panning command" do
      sc_command = "SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0);"

      pan_sc_command = "Pan2.ar(SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0););"

      assert sc_command |> Pan.center() == pan_sc_command
    end

    test "for %Ugen{} default panning command" do
      ugen = %Ugen{sc_command: "SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0);"}

      pan_sc_command = "Pan2.ar(SinOsc.ar(freq: 369, phase: 0, mul: 0.1, add: 0););"

      %Ugen{sc_command: new_sc_command} = ugen |> Pan.center()
      assert new_sc_command == pan_sc_command
    end
  end
end
