use Amnesia

defdatabase Database do

    deftable Player

    deftable Player, [:id, :name, :x, :y, :angle, :showFlame, :color, :killCount], type: :ordered_set, index: [:name] do
        @type t :: %Player{id: String.t, name: String.t, x: Decimal.t, y: Decimal.t, angle: Decimal.t, showFlame: Boolean.t, color: String.t, killCount: Integer.t}
    end

end
