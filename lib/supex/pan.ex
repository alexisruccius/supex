defmodule Supex.Pan do
  @moduledoc """
  Module for panning the sound.

  By default SuperCollider uses only the left channel.
  With panning you can ajust this for two speakers.

  See SuperCollider's docs for `Pan2` https://doc.sccode.org/Classes/Pan2.html
  """

  alias Supex.Ugen

  @doc """
  Pans the sound in the center.

  By default SuperCollider uses only the left channel.
  So with this you get the mono signal on both speakers.
  """
  @doc since: "0.1.0"
  @spec center(binary() | %Supex.Ugen{}) :: <<_::64, _::_*8>> | %Supex.Ugen{}
  def center(%Ugen{} = ugen) do
    %Ugen{sc_command: sc_command} = ugen
    %Ugen{sc_command: sc_command |> center()}
  end

  @doc since: "0.1.0"
  def center(sc_command) when is_binary(sc_command) do
    "Pan2.ar(" <> sc_command <> ");"
  end
end
