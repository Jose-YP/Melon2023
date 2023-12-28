extends CharacterBody2D

@export var speed: int = 600
@export var bowDistance: int = 600
@export var arrow: PackedScene
@export var trap: PackedScene

@onready var bow = $RangedTools/Bow

var currentArrow
var drawingBow: bool = false
var meleeRange: bool = false
var stealthy: bool = false

enum location {HIGH,
	HOVERING,
	GROUNDED}
enum method {MISC,
	MELEE,
	TRAP}

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	pass

func _process(delta):
	#----------------------------------------------
	#REGULAR CONTROL
	#----------------------------------------------
	var direction = Input.get_vector("Left","Right","Up","Down")
	var aim = position + (get_global_mouse_position() - position).normalized()
	var effectiveSpeed = speed
	if drawingBow: #Player slows down when aiming
		effectiveSpeed = speed * .25
	
	position += direction * effectiveSpeed * delta
	move_and_slide()
	
	#----------------------------------------------
	#RANGED CONTROL
	#----------------------------------------------
	if not meleeRange:
		if drawingBow:
			if Input.is_action_pressed("Action"): #As long as action is held, keep aiming
				if direction == Vector2.ZERO:
					look_at(aim)
				bow.look_at(aim)
				currentArrow.position = bow.position
				currentArrow.look_at(aim)
			
			if Input.is_action_just_released("Action"): #When released shoot arrow
				drawingBow = false
				bow.hide()
				
				currentArrow.freeze = false
				currentArrow.linear_velocity = aim * bowDistance
				print("Shoot ", aim, "With: ", currentArrow.linear_velocity)
		else:
			if Input.is_action_just_pressed("Action"): #spawn the arrow
				drawingBow = true
				bow.look_at(aim)
				bow.show()
				
				currentArrow = arrow.instantiate()
				currentArrow.position = bow.position
				currentArrow.look_at(aim)
				currentArrow.show()
				currentArrow.freeze = true
				$RangedTools.add_child(currentArrow)

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func _on_melee_range_area_entered(_area):
	meleeRange = true
	print("Entered melee range")

func _on_melee_range_area_exited(_area):
	meleeRange = false
	print("Exited melee range")
