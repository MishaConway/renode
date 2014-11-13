defmodule Renode.WatcherTest do
  use ExUnit.Case
  import :meck
  import Renode.Watcher

  setup do
    new :net_kernel, [:unstick]
    new Node
    on_exit &unload/0
    :ok
  end

  test "init on empty list of nodes" do
    Application.put_env(:renode, :nodes, [])
    expect(:net_kernel, :monitor_nodes, [{[true], :ok}])

    assert init([]) == {:ok, HashSet.new}

    refute_receive :heartbeat, 2000
  end

  test "init on existing list of nodes" do
    Application.put_env(:renode, :nodes, [:node1, :node2])
    expect(:net_kernel, :monitor_nodes, [{[true], :ok}])
    expect(Node, :connect, [{[:node1], true}, {[:node2], false}])

    set = HashSet.new |> HashSet.put(:node2)

    assert init([]) == {:ok, set}

    assert_receive :heartbeat, 2000
  end

  test "handle_call delete node" do
    set = HashSet.new |> HashSet.put(:node)

    assert handle_call({:delete, :node}, :from, set) == {:reply, :ok, HashSet.new}
  end

  test "handle_info nodeup node" do
    set = HashSet.new |> HashSet.put(:node)

    assert handle_info({:nodeup, :node}, set) == {:noreply, HashSet.new}
  end
end
