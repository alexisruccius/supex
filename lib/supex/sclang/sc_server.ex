defmodule Supex.Sclang.ScServer do
  @moduledoc """
  Commands for a SC server, like booting or stop playing all sounds.
  """
  @moduledoc since: "0.1.0"

  alias Supex.Sclang

  require Logger

  @doc since: "0.1.0"
  @spec stop_playing :: <<_::72>>
  def stop_playing, do: "s.freeAll"

  @doc since: "0.1.0"
  @spec boot :: <<_::48>>
  def boot, do: "s.boot"

  @doc since: "0.1.0"
  @spec booted(Sclang.t()) :: Sclang.t()
  def booted(%Sclang{} = sclang) do
    booted_message()
    sclang |> struct!(sc_server_booted: true)
  end

  defp booted_message do
    Logger.info(
      "-------------------- SuperCollider Server booted!!! ----------------------------"
    )
  end
end
