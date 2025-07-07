defmodule Supex.Ugen do
  @moduledoc """
  For composing Oscillators and other SuperCollider's UGens (UnitGnerators).

  ## examples

  iex> import Supex.Ugen
  iex> osc() |> freq(690) |> phase(6) |> mul(0.9) |> add(0.69) |> name("y")
  %Supex.Ugen{add: 0.69, phase: 6, freq: 690, mul: 0.9, sc_command: "SinOsc.ar(freq: 690, phase: 6, mul: 0.9, add: 0.69);", sc_name: "y"}

  iex> alias Supex.Ugen
  iex> Ugen.osc(%Supex.Ugen{add: 0.69, phase: 6, freq: 690, mul: 0.9})
  %Supex.Ugen{add: 0.69, phase: 6, freq: 690, mul: 0.9, sc_command: "SinOsc.ar(freq: 690, phase: 6, mul: 0.9, add: 0.69);"}
  """

  defstruct osc: :sin,
            freq: 440,
            width: 0.5,
            phase: 0,
            mul: 0.1,
            add: 0,
            sc_command: "",
            sc_name: "x",
            lfo: false

  @oscillators [:sin, :saw, :pulse]

  @doc since: "0.1.0"
  @spec osc(:pulse | :saw | :sin | %Supex.Ugen{}) :: struct()
  def osc(type \\ :sin)

  def osc(type) when type in @oscillators,
    do: %__MODULE__{} |> struct!(osc: type) |> update_sc_command()

  def osc(%__MODULE__{} = ugen), do: ugen |> update_sc_command()

  @doc """
  Transforms a "normal" oscillator to a LFO.

  It uses `kr` (control rate) instead of `ar`(audio rate),
  cf. https://doc.sccode.org/Tutorials/Getting-Started/05-Functions-and-Sound.html
  """
  @doc since: "0.1.0"
  @spec lfo(%Supex.Ugen{}) :: binary()
  def lfo(%__MODULE__{} = ugen) do
    %__MODULE__{sc_command: sc_command} = ugen |> struct!(lfo: true) |> update_sc_command()
    sc_command
  end

  @doc since: "0.1.0"
  @spec freq(%Supex.Ugen{}, integer() | float() | binary()) :: struct()
  def freq(%__MODULE__{} = ugen, freq), do: ugen |> struct!(freq: freq) |> update_sc_command()

  @doc since: "0.1.0"
  @spec width(%Supex.Ugen{}, integer() | float() | binary()) :: struct()
  def width(%__MODULE__{} = ugen, width), do: ugen |> struct!(width: width) |> update_sc_command()

  @doc since: "0.1.0"
  @spec phase(%Supex.Ugen{}, integer() | float() | binary()) :: struct()
  def phase(%__MODULE__{} = ugen, phase), do: ugen |> struct!(phase: phase) |> update_sc_command()

  @doc since: "0.1.0"
  @spec mul(%Supex.Ugen{}, integer() | float() | binary()) :: struct()
  def mul(%__MODULE__{} = ugen, mul), do: ugen |> struct!(mul: mul) |> update_sc_command()

  @doc since: "0.1.0"
  @spec add(%Supex.Ugen{}, integer() | float() | binary()) :: struct()
  def add(%__MODULE__{} = ugen, add), do: ugen |> struct!(add: add) |> update_sc_command()

  @doc """
  Name the oscillator.
  SuperCollider only excepts single chars, like "y", "i"...
  """
  @doc since: "0.1.0"
  def name(%__MODULE__{} = ugen, sc_name), do: ugen |> struct!(sc_name: sc_name)

  @doc """
  Adding play to the sc_command, and naming it for referencing.

  You can pass a %Ugen{} struct or a SuperCollider's command.

  Supex and raw SuperCollider's command will by default refrenced with the variable "x".
  For example, you can stop playing it with `osc() |> name("x") |> stop()`
  """
  @doc since: "0.1.0"
  @spec play(binary() | %Supex.Ugen{}) :: <<_::64, _::_*8>>
  def play(%__MODULE__{} = ugen) do
    %__MODULE__{sc_command: sc_command, sc_name: sc_name} = ugen
    sc_name <> " = { " <> sc_command <> " }.play"
  end

  def play(sc_command) when is_binary(sc_command), do: "x = { " <> sc_command <> " }.play"

  @doc """
  Stop sc_command with name reference.
  """
  @doc since: "0.1.0"
  @spec stop(%Supex.Ugen{}) :: <<_::48, _::_*8>>
  def stop(%__MODULE__{} = ugen) do
    %__MODULE__{sc_name: sc_name} = ugen
    sc_name <> ".free\n"
  end

  defp update_sc_command(%__MODULE__{} = ugen) do
    %__MODULE__{osc: osc, lfo: lfo} = ugen
    ugen |> struct!(sc_command: ugen |> build_sc_command(osc) |> check_lfo(lfo))
  end

  defp build_sc_command(%__MODULE__{} = ugen, :sin) do
    %__MODULE__{freq: freq, phase: phase, mul: mul, add: add} = ugen
    "SinOsc.ar(freq: #{freq}, phase: #{phase}, mul: #{mul}, add: #{add});"
  end

  defp build_sc_command(%__MODULE__{} = ugen, :saw) do
    %__MODULE__{freq: freq, mul: mul, add: add} = ugen
    "Saw.ar(freq: #{freq}, mul: #{mul}, add: #{add});"
  end

  defp build_sc_command(%__MODULE__{} = ugen, :pulse) do
    %__MODULE__{freq: freq, width: width, mul: mul, add: add} = ugen
    "Pulse.ar(freq: #{freq}, width: #{width}, mul: #{mul}, add: #{add});"
  end

  defp check_lfo(sc_command, lfo) when lfo, do: sc_command |> String.replace("ar(", "kr(")
  defp check_lfo(sc_command, _lfo), do: sc_command
end
