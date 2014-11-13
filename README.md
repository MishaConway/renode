Renode
======

Elixir application to monitor and keep nodes connected.

Renode will start looking for the application env key `:nodes` to start connecting nodes. After this, it will monitor them and keep reconnecting if some node is disconnected.

It's also possible to add and remove nodes using `Renode.put/1` and `Renode.delete/1`

Todo:

* Add option to use `:net_adm.world/0`
* Use ETS instead of a HashSet
* Configurable heartbeat
* Integration tests
