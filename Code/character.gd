extends StaticBody2D

@onready var sprite: Sprite2D = $Icon
@onready var wanderArrays: Array[RayCast2D] = [$WanderRays/Forward,$WanderRays/Back]
@onready var idleTimers: Array[Timer] = [$IdleTimers/ShortIdle,$IdleTimers/MidIdle,$IdleTimers/LongIdle]

@export var speed: int = 20

var assignedType
var assignedMove
var currentDirection

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
	match assignedMove:
		move.WANDER:
			var atLeastOne = false
			for timer in idleTimers:
				if not timer.is_stopped():
					atLeastOne = true
			
			if not atLeastOne:
				idleTimers[randi_range(0,3)].start()
			
		move.SEEK:
			pass
		move.LEAVE:
			pass

#----------------------------------------------
#MOVING AI
#----------------------------------------------
func wander():
	if $Forward/Forward.is_colliding():
		pass
	else:
		pass

func seek():
	pass

func leave():
	pass

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
	wander()
