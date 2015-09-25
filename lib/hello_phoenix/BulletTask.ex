defmodule HelloPhoenix.BulletTask do
    use Database

    def start_link(bullet) do 
        Task.start(fn -> tick(bullet) end)
    end

    def tick(bullet) do
        tick_update(bullet)
    end

    def tick_update(bullet) do
         
        if bullet.age < 20 do
            Amnesia.transaction do
              bullet |> Bullet.write 
            end
            :timer.sleep(30)
            updated_bullet = %{bullet | x: bullet.x + bullet.vX, y: bullet.y + bullet.vY, age: bullet.age + 1}
            tick_update(updated_bullet)
        else
            HelloPhoenix.Endpoint.broadcast! "rawkets:game", "13", %{i: bullet.id} 
            Amnesia.transaction do
              b = Bullet.read(bullet.id)
              b |> Bullet.delete 
            end
        end

    end

    defp kill_player([], bulletId, playerId, x, y) do
        false
    end

    defp kill_player([head|tail], bulletId, playerId, x, y) do
        kill_radius = get_kill_radius(head, x, y)
    
        case {head.id == playerId, kill_radius < 10} do 
            {true, _} ->
              false
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
