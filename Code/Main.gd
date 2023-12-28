extends Node2D

@onready var player: CharacterBody2D = $Player

func _on_player_shoot_arrow(arrow,aim):
	arrow.get_parent().remove_child(arrow)
	$Projectiles.add_child(arrow)
	arrow.linear_velocity = player.aim.normalized() * player.bowDistance
	arrow.apply_central_impulse(arrow.linear_velocity)
	arrow.global_position = player.bow.global_position
	arrow.look_at(aim)
	
	player.drawingBow = false
	player.bow.hide()
	player.rotation = 0 #make this a tween later

func _on_player_whisper(target):
	print(target.whisperArea)
