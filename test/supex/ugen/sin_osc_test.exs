defmodule Supex.Ugen.SinOscTest do
  use ExUnit.Case, async: true

  alias Supex.Ugen.SinOsc

  describe "%SinOsc{} struct" do
    test "returns default %SinOsc{} struct" do
      assert %SinOsc{freq: 440, phase: 0, mul: 0.1, add: 0} = %SinOsc{}
    end
  end

  describe "command/1" do
    test "returns SinOsc command" do
      sin_osc = %SinOsc{freq: 69, phase: 0.9, mul: 0.6, add: 0.9}
      assert SinOsc.command(sin_osc) == "SinOsc.ar(freq: 69, phase: 0.9, mul: 0.6, add: 0.9);"
    end
  end
end
