extends StaticBody2D

@onready var sprite: Sprite2D = $Icon

@export var speed: int = 20

var assignedType

enum type {NONE,
	LOVER,
	TARGETTED}

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	moreReady()

func moreReady(): #Lover will inherit from Character so moreReady can be called on both scripts to keep them same
	pass

#----------------------------------------------
#PROCESSING
#----------------------------------------------
func _process(_delta):
	processor()

func processor(): #The same applies to processor and process
	pass

#----------------------------------------------
#MOVING AI
#----------------------------------------------

#----------------------------------------------
#OBSERVING AI
#----------------------------------------------
