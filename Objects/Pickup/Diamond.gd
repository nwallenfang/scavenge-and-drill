extends Spatial

var hp := 1.0
func get_drilled(delta):
	hp -= delta
	if hp <= 0.0:
		Game.drill.cooldown()
		$Pivot.visible = false
		$TreasureArea.picked_up()
