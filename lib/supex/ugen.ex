defmodule Supex.Ugen do
  @moduledoc """
  For composing Oscillators and other SuperCollider's UGens (UnitGnerators).

  ## examples

  iex> import Supex.Ugen
  iex> sin() |> freq(690) |> phase(6) |> mul(0.9) |> add(0.69)
  %Supex.Ugen.SinOsc{add: 0.69, phase: 6, freq: 690, mul: 0.9}
  """
  alias Supex.Ugen.Saw
  alias Supex.Ugen.SinOsc
  alias Supex.Ugen.Pulse

  defstruct sc_command: "", sc_name: "x"

  @doc """
  Create a sine oscillator.
  """
  def sin(), do: %SinOsc{}

  @doc """
  Create a saw oscillator.
  """
  def saw(), do: %Saw{}

  @doc """
  Create a pulse oscillator.
  """
  def pulse(), do: %Pulse{}

  @doc """
  Transforms a "normal" oscillator to a LFO.

  It uses `kr` (control rate) instead of `ar`(audio rate),
  cf. https://doc.sccode.org/Tutorials/Getting-Started/05-Functions-and-Sound.html
  """
  @doc since: "0.1.0"
  @spec lfo(struct()) :: struct()
  def lfo(ugen), do: ugen |> struct!(lfo: true)
  # def lfo(%{lfo: _lfo} = ugen), do: ugen |> struct!(lfo: true)

  @doc since: "0.1.0"
  @spec freq(struct(), integer() | float() | binary() | struct()) :: struct()
  def freq(ugen, freq), do: ugen |> struct!(freq: freq)

  @doc since: "0.1.0"
  @spec width(struct(), integer() | float() | binary() | struct()) :: struct()
  def width(ugen, width), do: ugen |> struct!(width: width)

  @doc since: "0.1.0"
  @spec phase(struct(), integer() | float() | binary() | struct()) :: struct()
  def phase(ugen, phase), do: ugen |> struct!(phase: phase)

  @doc since: "0.1.0"
  @spec mul(struct(), integer() | float() | binary() | struct()) :: struct()
  def mul(ugen, mul), do: ugen |> struct!(mul: mul)

  @doc since: "0.1.0"
  @spec add(struct(), integer() | float() | binary() | struct()) :: struct()
  def add(ugen, add), do: ugen |> struct!(add: add)
end
