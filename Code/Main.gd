extends Node2D

@export_range(2,6) var maxCharacters: int = 2
@export_range(1,3) var maxLovers: int = 1

@onready var player: CharacterBody2D = $Player
@onready var UI: CanvasLayer = $UI/CanvasLayer
@onready var spawnArray: Array[Marker2D] = [$SpawnLocations/RightSpawn,$SpawnLocations/LeftSpawn]
@onready var spawnTimers: Array[Timer] = [$SpawnTimers/ShortTimer,$SpawnTimers/MidTimer,$SpawnTimers/LongTimer]

signal riseScore
signal changeSuspect(ammount)

var characterArray: Array = []
var nonLoverArray: Array = []
var loverArray: Array = []
var currentCharacters: int = 2
var currentLovers: int = 1

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	for character in get_tree().get_nodes_in_group("Character"): #Will have both characters and lovers
		if character.assignedType == character.type.LOVER:
			loverArray.append(character)
		else:
			nonLoverArray.append(character)
		characterArray.append(character)
	
	for lover in get_tree().get_nodes_in_group("Lover"): #Will only have lovers
		lover.connect("convinced",_on_lover_convinced)
		getLoverCrush(lover)
	
	for timer in spawnTimers:
		timer.set_paused(false)
		timer.set_autostart(false)
		timer.connect("timeout",on_spawnTimer_timeout)
	
	print(loverArray)
	print(nonLoverArray)

func _process(_delta):
	if player.whispering:
		player.position = player.meleeFocus.whisperArea.global_position

#----------------------------------------------
#GAME LOOP
#----------------------------------------------
func spawnCharacter():
	pass

func spawnLover():
	pass

func loverConfidence(body):
	var distance = body.crush.global_position.x - body.global_position.x
	if not body.moving and abs(distance) > 150:
		body.assignedMove = body.move.LOVER
		body.crush.assignedMove = body.move.LOVER
		if body.crush.moving:
			body.crush.currentTween.kill()
			body.crush.moving = false
		
		
		print(distance)
		if distance * body.facing <= 0:
			print("Facing different directions", distance, body.scale.x)
			body.scale.x *= -1
			body.movement(distance)
		else:
			print("Facing same directions", distance, body.scale.x)
			body.movement(-1 * distance)
		
		body.inLove = true
		body.crush.inLove = true
	
	elif abs(distance) <= 150:
		if body.moving:
			body.currentTween.kill()
			body.moving = false
	

func riseLimits(character,lover = false):
	if character:
		pass
	if lover:
		pass

#----------------------------------------------
#FAIL STATE
#----------------------------------------------

func spotted():
	pass

func fail():
	pass

#----------------------------------------------
#HELPER FUNCTIONS
#----------------------------------------------
func getLoverCrush(currentLover):
	var tempCrush = characterArray[randi_range(0,characterArray.size()-1)] #For now brute force it
	while(tempCrush.crushedOn == false):
		
		if tempCrush.crushedOn == false and tempCrush != currentLover: #No narcicists
			currentLover.crush = tempCrush
			tempCrush.crushedOn = true
			break
		
		else:
			print("Hit")
			tempCrush = nonLoverArray[randi_range(0,nonLoverArray.size()-1)] 
	
	print(currentLover, "Crush: ",currentLover.crush)

func spottedCalc():
	var playerMod = player.getPlayerModifiers()
	var timerMod = (UI.totalTime - 5)/100
	return playerMod + timerMod

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
	arrow.connect("struckLover",on_lover_hit)
	
	#Get arrow velocity and shoot
	var arrowRotation = arrow.rotation
	var rotationVector = Vector2(cos(arrowRotation),sin(arrowRotation)) * -1
	arrow.linear_velocity = rotationVector * player.bowDistance
	arrow.apply_central_force(arrow.linear_velocity)
	
	#Reset player things
	player.bow.hide()
	player.rotation = 0 #make this a tween later

func _on_player_whisper(target):
	if target.canWhisper:
		player.position = target.whisperArea.global_position
		target.gettingWhispered = true

func _on_lover_convinced():
	player.whispering = false
	loverConfidence(player.meleeFocus)

func on_lover_hit(body):
	print("Hit ", body)
	loverConfidence(body)

func _on_hover_area_area_entered(_area):
	player.currentLocation = player.location.HOVER

func _on_high_area_area_entered(_area):
	player.currentLocation= player.location.HIGH

func on_spawnTimer_timeout():
	pass
