defmodule HelloPhoenix.BulletTask do
    use Database

    @message_type_add_bullet "11"
    @message_type_update_bullet "12"
    @message_type_remove_bullet "13"
    @message_type_kill_player "14"

    def start_link(playerId, x, y, vX, vY) do 
        Task.start(fn -> tick(playerId, x, y, vX, vY) end)
    end

    def tick(playerId, x, y, vX, vY) do 
        bulletId = get_current_time <> playerId
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", @message_type_add_bullet, %{i: bulletId, x: x, y: y} #add bullet
        :timer.sleep(30)
        tick_update(bulletId, playerId, x + vX, y + vY, 1, vX, vY)
    end

    def tick_update(bulletId, playerId, x, y, alive, vX, vY) do
        if alive < 20 do
            Amnesia.transaction do
                selection = Player.where alive == true
                if selection do
                    alive_players = selection |> Amnesia.Selection.values
                    if kill_player(alive_players, bulletId, playerId, x, y) == true do 
                        #do nothing process can die
                    else
                        HelloPhoenix.Endpoint.broadcast! "rawkets:game", @message_type_update_bullet, %{i: bulletId, x: x, y: y} #update bullet
                        :timer.sleep(30)
                        tick_update(bulletId, playerId, x + vX, y + vY, alive + 1, vX, vY)
                    end
                end
            end
 
        else
            HelloPhoenix.Endpoint.broadcast! "rawkets:game", @message_type_remove_bullet, %{i: bulletId} #remove bullet
        end
    end

    defp kill_player([], bulletId, playerId, x, y) do
        false
    end

    defp kill_player([head|tail], bulletId, playerId, x, y) do
        kill_radius = get_kill_radius(head, x, y)
    
        case {head.id == playerId, kill_radius < 10} do 
            {false, true} ->
                updated_player = %{head | alive: false}
                Amnesia.transaction do
                    updated_player |> Player.write
                    killer = Player.read(playerId)
                    updated_killer = %{killer | killCount: killer.killCount + 1}
                    updated_killer |> Player.write
                    HelloPhoenix.Endpoint.broadcast! "rawkets:game", @message_type_kill_player, %{i: head.id, ik: playerId, k: updated_killer.killCount } #kill player
                    HelloPhoenix.Endpoint.broadcast! "rawkets:game", @message_type_remove_bullet, %{i: bulletId} #remove bullet
                end
                true
            _ -> 
                kill_player(tail,bulletId, playerId, x, y)
        end
        
        false
    end

    defp get_kill_radius(player, bulletx, bullety) do 
        dx = bulletx - player.x
        dy = bullety - player.y
        dd = (dx * dx) + (dy * dy);
        :math.sqrt(dd);
    end

    defp get_current_time() do
        {ms, s, _} = :os.timestamp
        timestamp = (ms * 1_000_000 + s)
        to_string(timestamp)
    end

end
