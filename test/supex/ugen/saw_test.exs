defmodule Supex.Ugen.SawTest do
  use ExUnit.Case, async: true

  alias Supex.Ugen.Saw

  describe "%Saw{} struct" do
    test "returns default %SinOsc{} struct" do
      assert %Saw{freq: 440, mul: 0.1, add: 0} = %Saw{}
    end
  end

  describe "command/1" do
    test "returns Saw command" do
      saw = %Saw{freq: 69, mul: 0.6, add: 0.9}
      assert Saw.command(saw) == "Saw.ar(freq: 69, mul: 0.6, add: 0.9);"
    end
  end
end
