extends RigidBody2D

@onready var arrowTime = $Timer

var sticking: bool = false
var stickPos: Vector2
var direction: Vector2 = Vector2.UP

func _ready():
	arrowTime.set_paused(false)
	arrowTime.set_autostart(false)

func _process(_delta):
#	print(arrowTime.time_left)
	if sticking == true:
		position = stickPos

func _on_timer_timeout(): #Despawn
	queue_free()

func _on_stick_area_area_entered(area): #Stick to whatever it hits
	stickPos = position
	sticking = true
	arrowTime.start()
