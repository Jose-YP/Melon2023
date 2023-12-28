extends CharacterBody2D

@export var speed: int = 600
@export var bowDistance: int = 600
@export var arrow: PackedScene
@export var trap: PackedScene

@onready var bow = $RangedTools/Bow

var drawingBow: bool = false
var meleeRange: bool = false
var stealthy: bool = false

enum location {HIGH,
	HOVERING,
	GROUNDED}
enum method {MISC,
	MELEE,
	TRAP}

func _ready():
	pass

func _process(delta):
	#REGULAR CONTROL
	var direction = Input.get_vector("Left","Right","Up","Down")
	var aim = get_global_mouse_position() - position
	var effectiveSpeed = speed
	if drawingBow: #Player slows down when aiming
		effectiveSpeed = speed * .25
	
	position += direction * effectiveSpeed * delta
	move_and_slide()
	
	#RANGED CONTROL
	if not meleeRange:
		if drawingBow:
			if Input.is_action_just_released("Action"): #When released shoot arrow
				drawingBow = false
				bow.hide()
				print("Shoot ", aim)
		else:
			if Input.is_action_pressed("Action"): #As long as action is held, keep aiming
				drawingBow = true
				bow.look_at(aim)
				bow.show()
				print("Looking at ", aim)

func _on_melee_range_area_entered(area):
	meleeRange = true
	print("Entered melee range")

func _on_melee_range_area_exited(area):
	meleeRange = false
	print("Exited melee range")
