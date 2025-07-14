defmodule Supex.Command do
  @moduledoc """
  Module for SuperCollider commands rendering.
  """

  @doc """
  Builds the SuperCollider command from a ugen struct.
  """
  def build(ugen), do: ugen |> to_sc_command()

  @doc """
  Adding play to the sc_command.

  SuperCollider's command will by default refrenced with the variable "x".
  For example, you can stop playing it with `stop("x")`
  """
  def play(sc_command), do: "x = { " <> sc_command <> " }.play"

  @doc """
  Adding play to the sc_command, and naming it for referencing.

  SuperCollider's command will be refrenced with the given name.
  You can stop playing it with this name `stop("<name>")`

  Although SuperCollider only excepts single chars as global vars, like "y", "i",
  you can also use more than one char for variables.
  These will be declared as SuperCollider's environmental vars.
  """
  def play(sc_command, name) when byte_size(name) == 1,
    do: name <> " = { " <> sc_command <> " }.play"

  def play(sc_command, name), do: "~" <> name <> " = { " <> sc_command <> " }.play"

  @doc """
  Command for stopping sound playing referenced by name.
  """
  def stop(name) when byte_size(name) == 1, do: name <> ".free\n"
  def stop(name), do: "~" <> name <> ".free\n"

  defp to_sc_command(ugen) when is_struct(ugen) do
    struct_module = ugen.__struct__
    struct_module.command(ugen |> build_commands_for_lfos())
  end

  defp build_commands_for_lfos(ugen) do
    new_key_values =
      ugen |> Map.from_struct() |> Enum.map(fn {k, v} -> {k, check_for_struct(v)} end)

    ugen |> struct!(new_key_values)
  end

  defp check_for_struct(value) when is_struct(value), do: value |> to_sc_command()
  defp check_for_struct(value), do: value
end
