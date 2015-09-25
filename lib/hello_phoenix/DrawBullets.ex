defmodule HelloPhoenix.DrawBullets do 
  use Database

  def tick() do

    Amnesia.transaction do 
        selection = Bullet.where id != nil
        if selection do
            all_bullets = selection |> Amnesia.Selection.values
            Enum.each(all_bullets, fn(b) -> draw(b) end)
        end
    end

  end

  defp draw(bullet) do 
    HelloPhoenix.Endpoint.broadcast! "rawkets:game", "12", %{i: bullet.id, x: bullet.x, y: bullet.y} 
  end

end
