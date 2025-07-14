defmodule Supex.Ugen.Pan2Test do
  use ExUnit.Case, async: true

  alias Supex.Ugen.Pan2

  describe "%Pan2{} struct" do
    test "returns default %Pan2{} struct" do
      assert %Pan2{in: "SinOsc.ar(440)", pos: 0, level: 1} = %Pan2{}
    end
  end

  describe "command/1" do
    test "returns Pan2 audio-rate command" do
      pan = %Pan2{in: "SinOsc.ar(440)", pos: 0.5, level: 1.0}
      assert Pan2.command(pan) == "Pan2.ar(SinOsc.ar(440), pos: 0.5, level: 1.0);"
    end
  end
end
