extends StaticBody2D

@onready var sprite: Sprite2D = $Icon
@onready var wanderArrays: Array[RayCast2D] = [$WanderRays/Forward,$WanderRays/Back]
@onready var idleTimers: Array[Timer] = [$IdleTimers/ShortIdle,$IdleTimers/MidIdle,$IdleTimers/LongIdle]

@export var tweenSpeed: int = 20

signal left(body)

var assignedType
var assignedMove
var currentDirection
var currentTween
var facing: int = 1
var moving: bool = false
var crushedOn: bool = false
var inLove: bool = false
var hit: bool = false

enum type {NONE,
	LOVER,
	TARGETTED}
enum move {WANDER,
	SEEK,
	LEAVE,
	SPAWN,
	LOVER}
enum lookDirections{FORWARD,
	UPFORWARD,
	UPWARD}
#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	moreReady()

func moreReady(): #Lover will inherit from Character so moreReady can be called on both scripts to keep them same
	for timer in idleTimers:
		timer.set_paused(false)
		timer.set_autostart(false)
		timer.connect("timeout",on_idleTimer_timeout)
	
	global_position.y = 520

#----------------------------------------------
#PROCESSING
#----------------------------------------------
func _process(_delta):
	processor()

func processor(): #The same applies to processor and process
	match assignedMove:
		move.WANDER:
			if not moving:
				var atLeastOne = false
				for timer in idleTimers:
					if not timer.is_stopped():
						atLeastOne = true
				
				if not atLeastOne:
					idleTimers[randi_range(0,2)].start()
			if moving:
				#print(global_position.x, currentTween)
				if $WanderRays/Forward.is_colliding() or global_position.x < 0:
					currentTween.kill()
					moving = false
			
			#Ducttape to keep characters inside screen
			if global_position.x < 5:
				print("Oh no,",global_position, "global position will now be", 0)
				global_position.x = 10
				currentTween.kill()
				moving = false
				
			elif global_position.x > 1100:
				print("Oops, global position will now be", global_position)
				global_position.x = 1100
				currentTween.kill()
				moving = false
				
			
		move.SEEK:#Unfinished
			if moving:
				if $WanderRays/Forward.is_colliding():
					currentTween.kill()
					moving = false
		
		move.LEAVE:
			await movement(1000)
			
			if global_position.x > 1300 or global_position.x < -500:
				despawn()
		
		move.SPAWN:
			await spawnMovement(randi_range(500,700))
			
			if global_position.x > 100 and global_position.x < 800:
				print("Wandering again")
				assignedMove = move.WANDER
				moving = false

#----------------------------------------------
#MOVING AI
#----------------------------------------------
func wander():
	if $WanderRays/Forward.is_colliding():
		scale.x *= -1
		facing *= -1
		await movement(randi_range(200,300))
	elif $WanderRays/Back.is_colliding():
		await movement(randi_range(200,300))
	else:
		if randi_range(0,3) != 1: #1/4th chance of moving back
			scale.x *= -1
			facing *= -1
		await movement(randi_range(200,300))

func seek():
	pass

func movement(distance):
	distance *= facing
	moving = true
	print(global_position.x)
	var finalPos = global_position.x + distance
	if assignedMove == move.WANDER:
		if finalPos < 0:
			print("FinalPos: ", finalPos)
			finalPos = distance * -1
			scale.x *= -1
			facing *= -1
			print("FinalPos: ", finalPos)
	
	print("Going to: ", finalPos, " Direction: ", facing)
	print(name,":",global_position)
	var moveTween = get_tree().create_tween().bind_node(self)
	currentTween = moveTween
	moveTween.connect("finished",on_movementTween_finished)
	
	moveTween.tween_property($".","global_position",Vector2(finalPos,global_position.y),abs(distance)/(tweenSpeed))

func spawnMovement(distance):
	distance *= facing
	moving = true
	
	var moveTween = get_tree().create_tween().bind_node(self)
	currentTween = moveTween
	moveTween.connect("finished",on_movementTween_finished)
	#print("Currently: ", global_position, "Destination: ", Vector2(distance,520))
	moveTween.tween_property($".","global_position",Vector2(distance,520),abs(distance)/(tweenSpeed * 1.5)).from_current()

#----------------------------------------------
#OBSERVING AI
#----------------------------------------------
func pasiveForwardObserve():
	pass

func passiveUpForObserve():
	pass

func activeObserve():
	pass

func activeSkyObserve():
	pass

#----------------------------------------------
#HELPER FUNTIONS
#----------------------------------------------
func despawn():#Will have other stuff to determine what should be done before they despawn
	left.emit(self)
	print("Despawn?")
	queue_free()

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func on_idleTimer_timeout():
	if not moving:
		wander()

func on_movementTween_finished():
	moving = false
