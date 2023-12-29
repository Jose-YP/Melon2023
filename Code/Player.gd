extends CharacterBody2D

@export var speed: int = 600
@export var bowDistance: int = 600
@export var whisperSpeed: int = 1
@export var arrow: PackedScene
@export var trap: PackedScene

@onready var bow: Sprite2D = $RangedTools/Bow
@onready var bowCooldown: Timer = $RangedTools/BowCooldown
@onready var meleeInvisTime: Timer = $MeleeTools/InvisTimer

signal shootArrow(arrow, aim)
signal whisper(target)

var currentArrow
var meleeFocus
var currentLocation
var currentMethod
var direction: Vector2
var aim: Vector2
var bowPosition: Vector2
var bowAllowed: bool = true
var drawingBow: bool = false
var meleeRange: bool = false
var whispering: bool = false
var stealthy: bool = false

enum location {HIGH,
	HOVER,
	GROUNDED}
enum method {MISC,
	MELEE,
	TRAP}

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	bowCooldown.set_paused(false)
	bowCooldown.set_autostart(false)
	meleeInvisTime.set_paused(false)
	meleeInvisTime.set_autostart(false)

func _process(delta):
	if not whispering:
		basicMove(delta)
		
		if not meleeRange and bowAllowed:
			rangedMove()
	
		elif meleeRange:
			meleeMove()
	
	else:
		if Input.is_action_just_released("Action"):
			whispering = false
			meleeFocus.gettingWhispered = false
	

#----------------------------------------------
#BASIC CONTROL
#----------------------------------------------
func basicMove(delta):
	direction = Input.get_vector("Left","Right","Up","Down")
	aim = position + (get_global_mouse_position() - position).normalized()
	var effectiveSpeed = speed
	if drawingBow: #Player slows down when aiming
		effectiveSpeed = speed * .25
	
	position += direction * effectiveSpeed * delta
	move_and_slide()

#----------------------------------------------
#RANGED CONTROL
#----------------------------------------------
func rangedMove():
	bowPosition = (bow.global_position * aim.normalized()) + position
	
	if drawingBow:
		if Input.is_action_pressed("Action"): #As long as action is held, keep aiming
			if direction == Vector2.ZERO:
				look_at(aim)
			bow.look_at(aim)
			currentArrow.position = bow.position
			currentArrow.look_at(aim)

		if Input.is_action_just_released("Action"): #When released shoot arrow
			currentArrow.freeze = false
			currentArrow.arrowTime.start()
			shootArrow.emit(currentArrow, aim)
			
			bowAllowed = false
			drawingBow = false
			bowCooldown.start()
	
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
#MELEE CONTROL
#----------------------------------------------
func meleeMove():
	if Input.is_action_just_pressed("Action"):
		whisper.emit(meleeFocus)
		whispering = true

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func _on_bow_cooldown_timeout():
	bowAllowed = true

func _on_melee_range_area_entered(area): #Make sure sprite has enough empty space to have an outline
	meleeRange = true
	meleeFocus = area.get_parent()
	meleeFocus.sprite.use_parent_material = false

func _on_melee_range_area_exited(area):
	meleeRange = false
	meleeFocus = area.get_parent()
	meleeFocus.sprite.use_parent_material = true

func _on_invis_timer_timeout():
	stealthy = false
