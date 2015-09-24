defmodule HelloPhoenix.PlayerAgent do
    use Database
    
    @message_type_update_player "5"

    def start_link(player) do
        Agent.start_link(fn -> initial_state(player) end, name: via_name(player.name))
    end

    def update(playerName, x, y, a, f) do
        old = Agent.get(via_name(playerName), fn state -> state end)
        new = %{old | x: x, y: y, angle: a, showFlame: f}
        Amnesia.transaction do
              new = %{old | x: x, y: y, angle: a, showFlame: f}
              new |> Player.write
        end
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", @message_type_update_player, %{i: playerName, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: playerName, k: 0} 
    end

    defp initial_state(player) do 
        Amnesia.transaction do
            player |> Player.write
        end
        player
    end

    defp via_name(playerName) do
        {:via, :gproc, player_name(playerName)}
    end

    defp player_name(playerName) do
        {:n, :l, {__MODULE__, playerName}}
    end

end
