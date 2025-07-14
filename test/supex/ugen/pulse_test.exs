defmodule Supex.Ugen.PulseTest do
  use ExUnit.Case, async: true

  alias Supex.Ugen.Pulse

  describe "%Pulse{} struct" do
    test "returns default %SinOsc{} struct" do
      assert %Pulse{freq: 440, width: 0, mul: 0.1, add: 0} = %Pulse{}
    end
  end

  describe "command/1" do
    test "returns Pulse command" do
      pulse = %Pulse{freq: 69, width: 0.2, mul: 0.6, add: 0.9}
      assert Pulse.command(pulse) == "Pulse.ar(freq: 69, width: 0.2, mul: 0.6, add: 0.9);"
    end

    test "for LFO true returns Pulse command with kr" do
      pulse = %Pulse{freq: 69, width: 0.2, mul: 0.6, add: 0.9, lfo: true}
      assert Pulse.command(pulse) == "Pulse.kr(freq: 69, width: 0.2, mul: 0.6, add: 0.9);"
    end
  end
end
