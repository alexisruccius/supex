defmodule Supex.Sclang.ScServerTest do
  use ExUnit.Case

  alias Supex.Sclang.ScServer

  describe "boot/0" do
    test "boot server command" do
      assert ScServer.boot() == "s.boot"
    end
  end

  describe "stop_playing/0" do
    test "stop playing all sounds" do
      assert ScServer.stop_playing() == "s.freeAll"
    end
  end
end
