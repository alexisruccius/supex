defmodule Supex.Ugen.Pan2 do
  @moduledoc """
  Module for the SuperCollider Pan2 panning unit,
  see https://doc.sccode.org/Classes/Pan2.html

  Defines a `%Pan2{}` struct with:

  - `in`: input signal (usually a string expression)
  - `pos`: pan position (-1.0 = left, 0 = center, 1.0 = right), defaults to center.
  - `level`: output level scaling
  """

  defstruct in: "SinOsc.ar(440)", pos: 0, level: 1

  @doc """
  Builds the SuperCollider command from the `%Pan2{}` struct.

  ## Examples

      iex> %Pan2{in: "SinOsc.ar(440)", pos: 0.5, level: 1.0, lfo: false}
      "Pan2.ar(SinOsc.ar(440), pos: 0.5, level: 1.0);"

      iex> %Pan2{in: "SinOsc.kr(2)", pos: -0.5, level: 0.8, lfo: true}
      "Pan2.kr(SinOsc.kr(2), pos: -0.5, level: 0.8);"
  """
  @spec command(struct()) :: binary()
  def command(%__MODULE__{in: input, pos: pos, level: level}) do
    "Pan2.ar(#{input}, pos: #{pos}, level: #{level});"
  end
end
