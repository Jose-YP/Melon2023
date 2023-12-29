extends StaticBody2D

@onready var sprite: Sprite2D = $Icon
@onready var wanderArrays: Array[RayCast2D] = [$WanderRays/Forward,$WanderRays/Back]
@onready var idleTimers: Array[Timer] = [$IdleTimers/ShortIdle,$IdleTimers/MidIdle,$IdleTimers/LongIdle]

@export var tweenSpeed: int = 20

var assignedType
var assignedMove
var currentDirection
var currentTween
var facing: int = 1
var moving: bool = false

enum type {NONE,
	LOVER,
	TARGETTED}
enum move {WANDER,
	SEEK,
	LEAVE}
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
	
	assignedMove = move.WANDER

#----------------------------------------------
#PROCESSING
#----------------------------------------------
func _process(_delta):
	processor()

func processor(): #The same applies to processor and process
	if not moving:
		match assignedMove:
			move.WANDER:
				var atLeastOne = false
				for timer in idleTimers:
					if not timer.is_stopped():
						atLeastOne = true
				
				if not atLeastOne:
					idleTimers[randi_range(0,2)].start()
				
			move.SEEK:
				pass
			move.LEAVE:
				pass
	
	if moving:
		if $WanderRays/Forward.is_colliding():
			currentTween.kill()
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
			scale.x = scale.x * -1
			facing *= -1
		await movement(randi_range(200,300))

func seek():
	pass

func leave():
	pass

func movement(distance):
	distance *= facing
	moving = true
	print("Making: ", moving, "Direction: ", facing)
	var finalPos = position.x + distance
	
	var moveTween = get_tree().create_tween().bind_node(self)
	currentTween = moveTween
	moveTween.connect("finished",on_movementTween_finished)
	
	moveTween.tween_property($".","position",Vector2(finalPos,position.y),abs(distance)/tweenSpeed)

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

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func on_idleTimer_timeout():
	if not moving:
		wander()

func on_movementTween_finished():
	moving = false
	print("Done")
