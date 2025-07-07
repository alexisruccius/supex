defmodule Supex do
  @moduledoc """
  Supex = SuperCollider + Elixir

  An Elixir wrapper for the music live-coding language SuperCollider.
  Supex communicates with SuperCollider’s `sclang` tool, letting you generate and control sound directly from Elixir.

  - 🎧 Play basic oscillators with a clean, pipeable syntax
  - 🔤 Send raw SuperCollider code when needed
  - ⛔ Stop sounds by name

  Built for musicians, coders, and live performers who want to use Elixir for audio synthesis.

  👉 Requires `sclang` installed (`sudo apt install sclang` on Linux)


  ## Installation

  The package can be installed by adding `supex` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:supex, "~> 0.1.0"}
  ]
  end
  ```

  ## 🔍 Learn SuperCollider basics

  https://doc.sccode.org/Tutorials/Getting-Started/00-Getting-Started-With-SC.html

  ## ⚙️ Requirements:
  SuperCollider's `sclang` must be installed.
  Example (Linux): `sudo apt install sclang`

  ## 🟢 Start the SuperCollider sclang server

  ```elixir
  iex> Supex.Sclang.start_link(:ok)
  ```

  ## 💡 Examples

  ️▶ Play a sine oscillator at 269 Hz and name it "y"; then stop it:

  ```elixir
  iex> import Supex
  iex> osc |> freq(269) |> name("y") |> play
  iex> osc |> name("y") |> stop
  ```

  ▶ Modulate volume of a sine wave using another sine as LFO:

  ```elixir
  iex> import Supex
  iex> osc |> mul(osc |> freq(2) |> mul(0.4) |> add(0.5) |> lfo) |> play
  iex> osc |> stop
  ```

  ▶ Modulate a pulse wave's frequency and width:

  ```elixir
  iex> import Supex
  iex> osc(:pulse) |> freq("SinOsc.kr(0.4).range(169, 269)") |> width("SinOsc.kr(6.9).range(0.01, 0.8)")|> mul(0.3) |> name("x") |> play
  iex> osc |> name("x") |> stop
  ```

  🔤 Send a raw SuperCollider expression:

  ```elixir
  iex> import Supex
  iex> "RLPF.ar(Pulse.ar([100, 250], 0.5, 0.1), XLine.kr(8000, 400, 5), 0.05)" |> play
  iex> osc |> name("z") |> stop
  ```

  ## ⚠️ Disclaimer

  SuperCollider and Supex can produce loud, sudden sounds.
  Use volume control and a limiter to protect your ears.
  Avoid hearing damage.
  """

  alias Supex.Pan
  alias Supex.Synth
  alias Supex.Sclang
  alias Supex.Ugen

  @spec osc() :: struct()
  @doc """
  Create a oscillator.
  `type` can be:

    `:sin` (sinus wave)
    `:saw` (saw wave)
    `:pulse` (pulse wave, aka square wave)

  Defaults to `:sin`.
  """
  @doc since: "0.1.0"
  defdelegate osc(type \\ :sin), to: Ugen

  @doc """
  Transforms a "normal" oscillator to a LFO to use it as a modulator.

  It uses `kr` (control rate) instead of `ar`(audio rate),
  cf. https://doc.sccode.org/Tutorials/Getting-Started/05-Functions-and-Sound.html

  ## example

  Modulate the volume of a sine wave with another sine wave as an LFO:

    iex> import SC
    iex> osc |> mul(osc |> freq(3) |> mul(0.5) |> add(0.5) |> lfo) |> play
    iex> osc |> stop

    or

    iex> osc(:pulse) |> mul(osc|>freq(2)|>mul(0.4)|>add(0.5)|>lfo) |> freq(osc(:saw)|>freq(0.2)|>mul(100)|>add(100)|>lfo) |> play
  """
  @doc since: "0.1.0"
  @spec lfo(%Supex.Ugen{}) :: binary()
  def lfo(%Ugen{} = ugen) do
    %Ugen{sc_command: sc_command} = ugen |> Ugen.lfo()
    sc_command
  end

  @doc """
  Tune the frequency of an oscillator.
  `freq` can be an integer or float.
  """
  @doc since: "0.1.0"
  @spec freq(%Ugen{}, integer() | float() | binary()) :: struct()
  defdelegate freq(ugen, freq), to: Ugen

  @doc """
  The pulse width of an pulse wave oscillator.
  `width` should be a value between `0.01` and `0.99`.
  """
  @doc since: "0.1.0"
  @spec width(%Ugen{}, integer() | float() | binary()) :: struct()
  defdelegate width(ugen, width), to: Ugen

  @doc """
  The phase of a sinus wave.
  """
  @doc since: "0.1.0"
  @spec phase(%Ugen{}, integer() | float() | binary()) :: struct()
  defdelegate phase(ugen, phase), to: Ugen

  @doc """
  Multiplication of the signal.
  Chose values between `0.1` and `1` for not hurting your ears.
  """
  @doc since: "0.1.0"
  @spec mul(%Ugen{}, integer() | float() | binary() | binary()) :: struct()
  defdelegate mul(ugen, mul), to: Ugen

  @doc """
  Add the value to the signal.
  Values can be `0.1` or `1` for example.
  """
  @doc since: "0.1.0"
  @spec add(%Ugen{}, integer() | float() | binary()) :: struct()
  defdelegate add(ugen, add), to: Ugen

  @doc """
  Adds a name for referencing.
  e.g. with a name the singnal can be stopped on the SuperCollider server.
  """
  @doc since: "0.1.0"
  @spec name(%Ugen{}, binary()) :: struct()
  defdelegate name(ugen, name), to: Ugen

  @doc """
  A synth definition.
  """
  @doc since: "0.1.0"
  @spec synth(binary()) :: binary()
  defdelegate synth(name), to: Synth, as: :define

  @doc """
  Play the composed oscillator, or a raw SuperCollider's command (as a string).

  ## example

    iex> import SC
    iex> osc |> freq(269) |> name("y") |> play
  """
  @doc since: "0.1.0"
  @spec play(%Ugen{sc_command: binary(), sc_name: binary()} | binary()) :: :ok
  def play(%Ugen{} = ugen), do: ugen |> Pan.center() |> Ugen.play() |> Sclang.execute()

  @doc since: "0.1.0"
  def play(sc_command) when is_binary(sc_command),
    do: sc_command |> Pan.center() |> Ugen.play() |> Sclang.execute()

  @doc """
  Stop playing a oscillator with a name.

  ## example

    iex> import SC
    iex> osc |> name("y") |> stop
  """
  @doc since: "0.1.0"
  @spec stop(%Ugen{sc_name: binary()}) :: :ok
  def stop(%Ugen{} = ugen) do
    ugen |> Ugen.stop() |> Sclang.execute()
  end

  @doc "Stops all sound playing."
  @doc since: "0.1.0"
  @spec stop_playing() :: :ok
  defdelegate stop_playing(), to: Sclang

  @doc """
  Executes a raw SuperCollider's command on the `sclang` server.

  Must be a string.
  """
  @doc since: "0.1.0"
  @spec execute(binary()) :: :ok
  defdelegate execute(sc_command), to: Sclang
end
