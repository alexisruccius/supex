defmodule Supex.Sclang do
  @moduledoc """
  Starts the port for SuperCollider's `sclang` and
  sends SuperCollider's commands to this `sclang` port.
  """
  @moduledoc since: "0.1.0"

  use GenServer

  alias Supex.Sclang
  alias Supex.Sclang.ScPort
  alias Supex.Sclang.ScServer

  require Logger

  @type t() :: %__MODULE__{
          port: port(),
          sc_server_booted: boolean(),
          last_command_executed: binary()
        }
  defstruct port: nil, sc_server_booted: false, last_command_executed: ""

  @doc """
  Starts `sclang` via a port,
  and boots the SuperCollider server.
  """
  @doc since: "0.1.0"
  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_init_arg), do: GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)

  @doc since: "0.1.0"
  @spec stop_playing :: Sclang.t()
  def stop_playing, do: ScServer.stop_playing() |> execute()

  @doc since: "0.1.0"
  @spec execute(binary()) :: Sclang.t()
  def execute(sc_command) when is_binary(sc_command) do
    case GenServer.call(__MODULE__, {:execute, sc_command}) do
      %{sc_server_booted: true} = sclang ->
        sclang

      %{sc_server_booted: false} = sclang ->
        warning_sclang_booting()
        sclang
    end
  catch
    :exit, _exit_value -> warning_sclang_not_started()
  end

  @doc since: "0.1.0"
  @spec close_port :: :ok
  def close_port, do: GenServer.cast(__MODULE__, :close_port)

  @impl GenServer
  def init(%__MODULE__{} = _sclang) do
    port = ScPort.open()
    ScServer.boot() |> ScPort.send_sc_command(port)
    {:ok, %__MODULE__{port: port}}
  end

  @impl GenServer
  def handle_call({:execute, sc_command}, _from, %__MODULE__{} = sclang) do
    %__MODULE__{port: port} = sclang
    {_port, {:command, command}} = sc_command |> ScPort.send_sc_command(port)
    sclang_new = sclang |> struct!(last_command_executed: command)
    {:reply, sclang_new, sclang_new}
  end

  @impl GenServer
  def handle_cast(:close_port, %__MODULE__{} = sclang) do
    %__MODULE__{port: port} = sclang
    ScPort.close(port)
    {:noreply, sclang |> struct!(port: nil, sc_server_booted: false)}
  end

  @impl GenServer
  def handle_info({_port, {:data, "SuperCollider 3 server ready.\n"}}, %__MODULE__{} = sclang) do
    {:noreply, sclang |> ScServer.booted()}
  end

  @impl GenServer
  def handle_info(
        {_port, {:data, "Shared memory server interface initialized\n"}},
        %__MODULE__{} = sclang
      ) do
    {:noreply, sclang |> ScServer.booted()}
  end

  @impl GenServer
  def handle_info({_port, {:data, "s.freeAll\n"}}, %__MODULE__{} = sclang) do
    Logger.info("--- All sounds stopped! ---")
    {:noreply, sclang}
  end

  @impl GenServer
  def handle_info({_port, {:data, data}}, %__MODULE__{} = sclang) do
    ("sc3(port)> " <> data) |> String.replace("\n", "") |> Logger.debug()
    {:noreply, sclang}
  end

  defp warning_sclang_booting do
    Logger.warning(
      "Sclang Server is booting, but not started yet! (Therefor no sound...) -> Please wait a second and try again."
    )
  end

  defp warning_sclang_not_started do
    Logger.warning("""
    Sclang Server not started! (Therefore no sound...)
    -> Start Sclang server with `Supex.Sclang.start_link(:ok)` or in your supervision tree with `Supex.Sclang`.
    """)
  end
end
