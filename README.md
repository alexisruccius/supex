# Supex

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