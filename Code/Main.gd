extends Node2D

@onready var player: CharacterBody2D = $Player

var characterArray: Array = []
var loverArray: Array = []

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	for character in get_tree().get_nodes_in_group("Character"): #Will have both characters and lovers
		pass
	
	for lover in get_tree().get_nodes_in_group("Lover"): #Will only have lovers
		lover.connect("convinced",_on_test_lover_convinced)
	

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func _on_player_shoot_arrow(arrow,aim):
	#Move arrow to projectiles so it won't be affected by player anymore
	arrow.get_parent().remove_child(arrow)
	$Projectiles.add_child(arrow)
	
	#Add back it's position, and rotation
	arrow.global_position = player.bow.global_position
	arrow.look_at(aim)
	#Get arrow velocity and shoot
	arrow.linear_velocity = player.aim.normalized() * player.bowDistance
	arrow.apply_central_force(arrow.linear_velocity)
	
	#Reset player things
	player.bow.hide()
	player.rotation = 0 #make this a tween later

func _on_player_whisper(target):
	if target.canWhisper:
		player.position = target.whisperArea.global_position
		target.gettingWhispered = true

func _on_test_lover_convinced(target):
	player.whispering = false
	
