defmodule Supex.Ugen.SinOsc do
  @moduledoc """
  Module for the SuperCollider SinOsc sine wave generator,
  see https://doc.sccode.org/Classes/SinOsc.html


  Defines a `%SinOsc{}` struct with

  `freq` frequency in Hertz,

  `phase`	phase in radians (should be within the range +-8pi),

  `mul` output will be multiplied by this value,

  `add` this value will be added to the output.

  """
  @moduledoc since: "0.2.0"

  defstruct freq: 440, phase: 0, mul: 0.1, add: 0, lfo: false

  @doc """
  Builds the SuperCollider command from the `%SinOsc{}` struct.

  ## example

  iex> %SinOsc{freq: 440, phase: 0, mul: 0.1, add: 0, lfo: false}
  "SinOsc.ar(freq: 440, phase: 0, mul: 0.1, add: 0);"

  iex> %SinOsc{freq: 440, phase: 0, mul: 0.1, add: 0, lfo: true}
  "SinOsc.kr(freq: 440, phase: 0, mul: 0.1, add: 0);"
  """
  @doc since: "0.2.0"
  @spec command(struct()) :: binary()
  def command(%__MODULE__{} = sin_osc) do
    %__MODULE__{freq: freq, phase: phase, mul: mul, add: add, lfo: lfo} = sin_osc
    "SinOsc.ar(freq: #{freq}, phase: #{phase}, mul: #{mul}, add: #{add});" |> check_lfo(lfo)
  end

  # `kr` (control rate) instead of `ar`(audio rate) for LFO usage
  defp check_lfo(sc_command, lfo) when lfo, do: sc_command |> String.replace("ar(", "kr(")
  defp check_lfo(sc_command, _lfo), do: sc_command
end
