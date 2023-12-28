extends CharacterBody2D

@export var speed: int = 600
@export var bowDistance: int = 600
@export var arrow: PackedScene

@onready var bow = $RangedTools/Bow

var drawingBow: bool = false
var meleeRange: bool = false

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
	
	position += direction * speed * delta
	move_and_slide()
	
	#RANGED CONTROL
	if not meleeRange:
		if drawingBow:
			if Input.is_action_just_released("Action"):
				drawingBow = false
		else:
			if Input.is_action_pressed("Action"):
				drawingBow = true
				bow.look_at(aim)
	
	
