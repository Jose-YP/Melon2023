extends RigidBody2D

@onready var arrowTime: Timer = $Timer

signal struckLover(body)

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
	sticking = true #Might make a tween to make it's despawn look better

#----------------------------------------------
#SIGNALS
#----------------------------------------------w
func _on_timer_timeout(): #Despawn
	queue_free()

func _on_stick_area_area_entered(area):
	stick()
	var struck = area.get_parent().get_parent()
	if struck.has_node("WhisperNodes"):
		struckLover.emit(struck)
		print("osodv")
