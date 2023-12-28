extends RigidBody2D

@onready var arrowTime = $Timer

var sticking: bool = false
var stickPos: Vector2

#----------------------------------------------
#INITIALIZATION AND PROCESS
#----------------------------------------------
func _ready():
	arrowTime.set_paused(false)
	arrowTime.set_autostart(false)

func _process(delta):
	if linear_velocity != Vector2.ZERO:
		position += linear_velocity * delta
		
		#print("Position: ", position, "Velocity: ", linear_velocity)
	if sticking == true:
		position = stickPos

#----------------------------------------------
#HELPER FUNCTIONS
#----------------------------------------------
func stick():
	stickPos = position
	linear_velocity = Vector2.ZERO
	freeze = true
	lock_rotation = true
	sticking = true

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func _on_timer_timeout(): #Despawn
	queue_free()

func _on_stick_area_area_entered(_area): #Stick to whatever it hits
	call_deferred("stick")
