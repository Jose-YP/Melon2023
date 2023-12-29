extends Node2D

@export_range(2,6) var maxCharacters: int = 2
@export_range(1,2) var maxLovers: int = 1
@export var characterScene: PackedScene
@export var LoverScene: PackedScene

@onready var player: CharacterBody2D = $Player
@onready var UI: CanvasLayer = $UI/CanvasLayer
@onready var spawnArray: Array[Marker2D] = [$SpawnLocations/RightSpawn,$SpawnLocations/LeftSpawn]
@onready var spawnTimers: Array[Timer] = [$SpawnTimers/ShortTimer,$SpawnTimers/MidTimer,$SpawnTimers/LongTimer]

signal riseScore
signal ohNo
signal changeSuspect(ammount)

var characterArray: Array = []
var currentCharacters: int = 0
var currentLovers: int = 0
var startedSpawning: bool = false

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	for character in get_tree().get_nodes_in_group("Character"): #Will have both characters and lovers
		if character.assignedType == character.type.LOVER:
			currentLovers += 1
		
		characterArray.append(character)
		character.connect("left",on_despawn)
		currentCharacters += 1
	
	for lover in get_tree().get_nodes_in_group("Lover"): #Will only have lovers
		lover.connect("convinced",_on_lover_convinced)
		getLoverCrush(lover)
	
	for timer in spawnTimers:
		timer.set_paused(false)
		timer.set_autostart(false)
		timer.connect("timeout",on_spawnTimer_timeout)

func _process(_delta):
	if player.whispering:
		player.position = player.meleeFocus.whisperArea.global_position
	
	if startedSpawning:
		var atLeastOne = false
		for timer in spawnTimers:
			if not timer.is_stopped():
				atLeastOne = true
		
		if not atLeastOne:
			spawnTimers[randi_range(0,2)].start()

#----------------------------------------------
#GAME LOOP
#----------------------------------------------
func spawnCharacter(location):
	var loverChance = false
	if currentLovers == 0 or randi_range(0,3) == 1:
		loverChance = true
	
	if currentLovers < maxLovers and loverChance:
		spawnCharaMini(location,LoverScene)
	else:
		spawnCharaMini(location,characterScene)

func spawnCharaMini(location,scenetype):
	var CharNew = scenetype.instantiate()
	CharNew.position = location
	CharNew.assignedMove = CharNew.move.SPAWN
	characterArray.append(CharNew)
	
	if scenetype == characterScene:
		$Characters.add_child(CharNew)
	else:
		$Lovers.add_child(CharNew)

func loverConfidence(body,crush):
	var distance = crush.global_position.x - body.global_position.x
	
	if not body.moving and abs(distance) > 150:
		body.assignedMove = body.move.LOVER
		crush.assignedMove = body.move.LOVER
		if crush.moving:
			crush.currentTween.kill()
			crush.moving = false
		
		if distance * body.facing <= 0: #If they're facing away from distance
			print("Facing different directions", distance, body.scale.x)
			body.scale.x *= -1
			body.movement(distance)
		else:#If they're facing towards from distance
			print("Facing same directions", distance, body.scale.x)
			body.movement(-1 * distance)
		
		body.inLove = true
		crush.inLove = true
	
	elif abs(distance) <= 150:
		if body.moving:
			body.currentTween.kill()
			body.moving = false
		
		#Make sure both parties face the same side
		if crush.scale.x != body.scale.x:
			print("Different Directions")
			crush.scale.x *= -1
			crush.facing *= -1
		
		body.assignedMove = body.move.LEAVE
		crush.assignedMove = body.move.LEAVE

func riseLimits(character,lover = false):
	if character and maxCharacters < 6:
		maxCharacters += 1
	if lover and maxLovers < 2:
		maxLovers += 1

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
	var tempCrush = characterArray[randi_range(0,characterArray.size())] #For now brute force it
	
	while(tempCrush.crushedOn == false):
		if tempCrush.crushedOn == false and tempCrush != currentLover: #No narcicists
			currentLover.crush = tempCrush
			tempCrush.crushedOn = true
			break
		
		else:
			print("Hit")
			tempCrush.crushedOn = false
			tempCrush = characterArray[randi_range(0,characterArray.size())] 
	
	print(currentLover, "Crush: ",currentLover.crush)

func spottedCalc():
	var playerMod = player.getPlayerModifiers()
	var timerMod = (UI.totalTime - 10)/100
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
	
	#Get arrow velocity and shoot
	var arrowRotation = arrow.rotation
	var rotationVector = Vector2(cos(arrowRotation),sin(arrowRotation)) * -1
	arrow.linear_velocity = rotationVector * player.bowDistance
	arrow.apply_central_force(arrow.linear_velocity)
	
	#Reset player things
	player.bow.hide()
	var resetTween = player.create_tween().bind_node(player)
	resetTween.tween_property(player,"rotation",0,1).set_trans(Tween.TRANS_BOUNCE)

func _on_player_whisper(target):
	if target.canWhisper:
		player.position = target.whisperArea.global_position
		target.gettingWhispered = true

func _on_lover_convinced(body,crush):
	player.whispering = false
	loverConfidence(body,crush)

func _on_hover_area_area_entered(_area):
	player.currentLocation = player.location.HOVER

func _on_high_area_area_entered(_area):
	player.currentLocation= player.location.HIGH

func _on_canvas_layer_start_spawning():
	startedSpawning = true

func on_despawn(body):
	currentCharacters -= 1
	characterArray.erase(body)
	
	if body.assignedType == body.type.LOVER:
		currentLovers -= 1
	
	if body.inLove:
		riseScore.emit()
	else:
		pass

func on_spawnTimer_timeout():
	print("Spawning time")
	print(currentCharacters, "vs. ", maxCharacters)
	if currentCharacters < maxCharacters:
		var marker = spawnArray[randi_range(0,1)]
		spawnCharacter(marker.position)
