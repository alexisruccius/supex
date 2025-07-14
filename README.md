# Supex

Supex = SuperCollider + Elixir

An Elixir wrapper for the music live-coding language SuperCollider.
Supex communicates with SuperCollider's `sclang` tool, letting you generate and control sound directly from Elixir.

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

▶ Play a sine oscillator at 269 Hz and name it "y", pan to center; then stop it:

```elixir
iex> import Supex
iex> sin |> freq(269) |> pan |> play("y")
iex> stop("y")
# or stop all
iex> stop
```

▶ Modulate volume of a sine wave using another sine as LFO:

```elixir
iex> import Supex
iex> sin |> mul(sin |> freq(2) |> mul(0.4) |> add(0.5) |> lfo) |> pan |> play
iex> sin |> stop
# or stop all
iex> stop
```

▶ Modulate a pulse wave's frequency and width:

```elixir
iex> import Supex
iex> pulse |> freq(saw |> freq(0.1) |> mul(100) |> add(100) |> lfo) |> width(sin |> freq(6) |> mul(0.5) |> add(0.5) |> lfo) |> pan |> play
iex> stop("x")
# or stop all
iex> stop
```

🔤 Send a raw SuperCollider expression:

```elixir
iex> import Supex
iex> "RLPF.ar(Pulse.ar([100, 250], 0.5, 0.1), XLine.kr(8000, 400, 5), 0.05)" |> pan |> play
iex> stop("x")
# or stop all
iex> stop
```

## ⚠️ Disclaimer

SuperCollider and Supex can produce loud, sudden sounds.
Use volume control and a limiter to protect your ears.
Avoid hearing damage.

## 🛠️ Note

Supex is in early development.
Expect API changes.
