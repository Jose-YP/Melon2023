extends RigidBody2D

@onready var arrowTime: Timer = $Timer

var sticking: bool = false
var stickPos: Vector2

#----------------------------------------------
#INITIALIZATION AND PROCESS
#----------------------------------------------
func _ready():
	arrowTime.set_paused(false)
	arrowTime.set_autostart(false)

func _process(_delta):
	if sticking == true:
		position = stickPos

#----------------------------------------------
#HELPER FUNCTIONS
#----------------------------------------------
func stick():
	stickPos = position
	linear_velocity = Vector2.ZERO
	sticking = true

#----------------------------------------------
#SIGNALS
#----------------------------------------------w
func _on_timer_timeout(): #Despawn
	queue_free()

func _on_stick_area_area_entered(_area):
	stick()
