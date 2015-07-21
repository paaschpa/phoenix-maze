use Amnesia

defdatabase Database do

    deftable Player

    deftable Player, [{ :id, autoincrement }, :name, :x, :y, :angle, :showFlame, :color, :killCount], type: :ordered_set, index: [:name] do
        @type t :: %Player{id: non_neg_integer, name: String.t, x: Decimal.t, y: Decimal.t, angle: Decimal.t, showFlame: Boolean.t, color: String.t, killCount: Integer.t}
    end

end