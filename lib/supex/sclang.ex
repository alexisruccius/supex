defmodule Supex.Sclang do
  @moduledoc """
  Starts the port for SuperCollider's `sclang` and
  sends SuperCollider's commands to this `sclang` port.
  """

  use GenServer
  require Logger

  alias Supex.Sclang.ScPort
  alias Supex.Sclang.ScServer

  defstruct port: nil, sc_server_booted: false

  @doc """
  Starts `sclang` via a port,
  and boots the SuperCollider server.
  """
  @doc since: "0.1.0"
  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_init_arg), do: GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)

  @doc since: "0.1.0"
  @spec stop_playing() :: :ok
  def stop_playing(), do: GenServer.cast(__MODULE__, :stop_playing)

  @doc since: "0.1.0"
  @spec execute(binary()) :: :ok
  def execute(sc_command) when is_binary(sc_command) do
    try do
      case GenServer.call(__MODULE__, {:execute, sc_command}) do
        %{sc_server_booted: true} = sclang ->
          sclang

        %{sc_server_booted: false} = sclang ->
          warning_sclang_booting()
          sclang
      end
    catch
      :exit, _ -> warning_sclang_not_started()
    end
  end

  @doc since: "0.1.0"
  @spec close_port() :: :ok
  def close_port(), do: GenServer.cast(__MODULE__, :close_port)

  @impl true
  def init(%__MODULE__{} = _sclang) do
    port = ScPort.open()
    ScServer.boot() |> ScPort.send_sc_command(port)
    {:ok, %__MODULE__{port: port}}
  end

  @impl true
  def handle_call({:execute, sc_command}, _from, %__MODULE__{} = sclang) do
    %__MODULE__{port: port} = sclang
    sc_command |> ScPort.send_sc_command(port)
    {:reply, sclang, sclang}
  end

  @impl true
  def handle_cast(:stop_playing, %__MODULE__{} = sclang) do
    %__MODULE__{port: port} = sclang
    ScServer.stop_playing() |> ScPort.send_sc_command(port)
    {:noreply, sclang}
  end

  @impl true
  def handle_cast(:close_port, %__MODULE__{} = sclang) do
    %__MODULE__{port: port} = sclang
    ScPort.close(port)
    {:noreply, sclang |> struct!(port: nil, sc_server_booted: false)}
  end

  @impl true
  def handle_info({_port, {:data, "SuperCollider 3 server ready.\n"}}, %__MODULE__{} = sclang) do
    {:noreply, sclang |> ScServer.booted()}
  end

  @impl true
  def handle_info(
        {_port, {:data, "Shared memory server interface initialized\n"}},
        %__MODULE__{} = sclang
      ) do
    {:noreply, sclang |> ScServer.booted()}
  end

  @impl true
  def handle_info({_port, {:data, "s.freeAll\n"}}, %__MODULE__{} = sclang) do
    Logger.info("--- All sounds stopped! ---")
    {:noreply, sclang}
  end

  @impl true
  def handle_info({_port, {:data, data}}, %__MODULE__{} = sclang) do
    Logger.debug(("sc3(port)> " <> data) |> String.replace("\n", ""))
    {:noreply, sclang}
  end

  defp warning_sclang_booting() do
    Logger.warning(
      "Sclang Server is booting, but not started yet! (Therefor no sound...) -> Please wait a second and try again."
    )
  end

  defp warning_sclang_not_started() do
    Logger.warning("""
    Sclang Server not started! (Therefor no sound...)
    -> Start Sclang server with `Supex.Sclang.start_link(:ok)` or in your supervision tree with `Supex.Sclang`.
    """)
  end
end
