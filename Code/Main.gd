extends Node2D

@onready var player = $Player

func _on_player_shoot_arrow(arrow,aim):
	arrow.position = player.bowPosition
	arrow.look_at(aim)
	arrow.get_parent().remove_child(arrow)
	$Projectiles.add_child(arrow)
	print(player.bowPosition)
	print(arrow.position, arrow.rotation)
	
	player.drawingBow = false
	player.bow.hide()
	player.rotation = 0 #make this a tween later
