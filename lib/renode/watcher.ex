defmodule Renode.Watcher do
  use GenServer
  require Logger
  import Enum, only: [empty?: 1]

  @heartbeat 1000

  @doc """
  Starts watcher.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    nodes = Application.get_env(:renode, :nodes, [])
    retry_set = build_retry_set(nodes)
    :ok = :net_kernel.monitor_nodes(true)
    unless empty?(retry_set), do: heartbeat!
    {:ok, retry_set}
  end

  def handle_info(:heartbeat, retry_set) do
    Logger.info "Heartbeat!"
    unless empty?(retry_set) do
      retry_set = build_retry_set(retry_set)
      unless empty?(retry_set), do: heartbeat!
    end
    {:noreply, retry_set}
  end

  def handle_info({:nodedown, node}, retry_set) do
    Logger.info "Node #{node} is down"
    retry_set =  HashSet.put(retry_set, node)
    heartbeat!
    {:noreply, retry_set}
  end

  def handle_info({:nodeup, node}, retry_set) do
    Logger.info "Node #{node} is up"
    retry_set = HashSet.delete(retry_set, node)
    {:noreply, retry_set}
  end

  def handle_info(msg, state) do
    Logger.error "Unexpected message: #{inspect msg}"
    {:noreply, state}
  end

  def handle_call({:put, node}, _from, retry_set) do
    retry_set = HashSet.put(retry_set, node)
    unless empty?(retry_set), do: heartbeat!
    {:reply, :ok, retry_set}
  end

  def handle_call({:delete, node}, _from, retry_set) do
    {:reply, :ok, HashSet.delete(retry_set, node)}
  end

  def terminate(_) do
    :net_kernel.monitor_nodes(false)
    :ok
  end

  defp build_retry_set(nodes) do
    nodes = for node <- nodes, do: connect!(node)
    for {:down, node} <- nodes, into: HashSet.new, do: node
  end

  defp connect!(node) do
    case Node.connect(node) do
      true ->
        Logger.info "Connected to #{node}"
        {:up, node}
      _ ->
        Logger.error "Failed to connect to #{node}"
        {:down, node}
    end
  end

  defp heartbeat!, do: Process.send_after(self, :heartbeat, @heartbeat)
end
