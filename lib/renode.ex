defmodule Renode do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [ worker(Renode.Watcher, [[name: Renode.Watcher]]) ]

    opts = [strategy: :one_for_one, name: Renode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def put(node) do
    GenServer.call(Renode.Watcher, {:put, node})
  end

  def delete(node) do
    GenServer.call(Renode.Watcher, {:delete, node})
  end
end
