defmodule Supex.Ugen.Pan2 do
  @moduledoc """
  Module for the SuperCollider Pan2 panning unit,
  see https://doc.sccode.org/Classes/Pan2.html

  Defines a `%Pan2{}` struct with:

  - `in`: input signal (usually a string expression)
  - `pos`: pan position (-1.0 = left, 0 = center, 1.0 = right), defaults to center.
  - `level`: output level scaling
  """
  @moduledoc since: "0.2.0"

  @type t() :: %__MODULE__{in: binary(), pos: number(), level: number()}
  defstruct in: "SinOsc.ar(440)", pos: 0, level: 1

  @doc """
  Builds the SuperCollider command from the `%Pan2{}` struct.

  ## Examples

      iex> alias Supex.Ugen.Pan2
      iex> %Pan2{in: "SinOsc.ar(440)", pos: 0.5, level: 1.0} |> Pan2.command()
      "Pan2.ar(SinOsc.ar(440), pos: 0.5, level: 1.0);"
  """
  @doc since: "0.2.0"
  @spec command(t()) :: binary()
  def command(%__MODULE__{in: input, pos: pos, level: level}) do
    "Pan2.ar(#{input}, pos: #{pos}, level: #{level});"
  end
end
