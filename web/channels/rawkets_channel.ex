defmodule HelloPhoenix.RawketsChannel do
    use Phoenix.Channel

    @message_type_ping "1"
    @message_type_update_ping "2"
    @message_type_new_player "3"
    @message_type_set_colour "4"
    @message_type_update_player "5"
    @message_type_remove_player "6"
    @message_type_authentication_passed "7"
    @message_type_authentication_failed "8"
    @message_type_authenticate "9"
    @message_type_error "10"
    @message_type_add_bullet "11"
    @message_type_update_bullet "12"
    @message_type_remove_bullet "13"
    @message_type_kill_player "14"
    @message_type_update_kills "15"
    @message_type_revive_player "16"

    def join("rawkets:game", auth_msg, socket) do
        {:ok, socket}
    end

    def join("rawkets:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in(@message_type_update_player, %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do 
        old = HelloPhoenix.GameAgent.get_player(i)

        if old do        
          new = %{old | x: x, y: y, angle: a, showFlame: f}
          HelloPhoenix.GameAgent.update_player(new)
        end

        broadcast! socket, @message_type_update_player, %{i: i, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 
        {:noreply, socket}
    end

    #in Authenticate out Authenticate_Passed
    def handle_in(@message_type_authenticate, %{"tat" => tat, "tats" => tats}, socket) do
      push socket, @message_type_authentication_passed, %{val: "true"}
      {:noreply, socket}
    end 

    #in NewPlayer out...
    def handle_in(@message_type_new_player, %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do
      #type set color
      p = %HelloPhoenix.Player{id: socket.id, name: i, x: x, y: y, angle: a, showFlame: f, color: "rgb(199, 68, 145)", killCount: 0, alive: true}

      #set color
      push socket, @message_type_set_colour, %{i: i, c: "rgb(199, 68, 145)"}

      #tell everyone about new player
      broadcast! socket, @message_type_new_player, %{i: socket.id, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 

      #tell new player about everyone
      all_players = HelloPhoenix.GameAgent.get_players() 
      Enum.each(all_players, fn(p) -> push socket, @message_type_new_player, %{i: p.name, x: p.x, y: p.y, a: p.angle, c: p.color, f: p.showFlame, n: p.name, k: p.killCount} end)

      #write new player to db
      HelloPhoenix.GameAgent.add_player(p)
      
      {:noreply, socket}
    end 

    #Create Bullet
    def handle_in(@message_type_add_bullet, %{"x" => x, "y" => y, "vX" => vX, "vY" => vY}, socket) do
        b = %HelloPhoenix.Bullet{id: get_current_time <> socket.id, playerId: socket.id, x: x, y: y, vX: vX, vY: vY, age: 0, alive: true}
        HelloPhoenix.GameAgent.add_bullet(b)

        broadcast! socket, @message_type_add_bullet, %{i: b.id, x: b.x, y: b.y}
        {:noreply, socket}
    end 

    def handle_in(@message_type_revive_player, %{"i" => i}, socket) do 
        HelloPhoenix.GameAgent.revive_player(i)
        {:noreply, socket}
    end

    def terminate(err, socket) do
      HelloPhoenix.GameAgent.remove_player(socket.id)

      broadcast! socket, @message_type_remove_player, %{i: socket.id} 
    end

    defp get_current_time() do
        {ms, s, _} = :os.timestamp
        timestamp = (ms * 1_000_000 + s)
        to_string(timestamp)
    end
    
    #Redis helpers
    #Not using Redis using Mnesia
    defp decode({:ok, :undefined}) do 
       Map.new 
    end

    defp decode(str) do
        chunks = Enum.chunk(elem(str,1),2)
        tuples = Enum.map(chunks, fn([x,y]) -> {x, Poison.decode!(y, as: HelloPhoenix.Player)} end) 
        Enum.into(tuples, %{})
    end

end
