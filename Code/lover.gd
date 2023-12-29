extends "res://Code/character.gd"

@export var whisperMax: int = 8

@onready var whisperArea: Marker2D = $MeleeNodes/MeleeArea
@onready var whisperGauge: TextureProgressBar = $WhisperNodes/WhisperGauge
@onready var whisperRateTime: Timer = $WhisperNodes/WhisperRate
@onready var whisperCooldown: Timer = $WhisperNodes/WhisperCooldown

signal convinced()

var canWhisper: bool = true
var gettingWhispered: bool = false

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	moreReady()
	assignedType = type.LOVER
	whisperRateTime.set_paused(false)
	whisperRateTime.set_autostart(false)
	whisperCooldown.set_paused(false)
	whisperCooldown.set_autostart(false)

#----------------------------------------------
#PROCESS
#----------------------------------------------
func _process(_delta):
	processor()
	if gettingWhispered:
		if whisperRateTime.is_stopped():
			whisperGauge.show()
			whisperRateTime.start()
	
	if whisperGauge.value == whisperMax:
		convinced.emit()
		whisperGauge.hide()
		canWhisper = false
		gettingWhispered = false
		$MeleeNodes/MeleeHitbox.monitorable = false
	
	if not gettingWhispered and canWhisper:
		if whisperCooldown.is_stopped():
			whisperCooldown.start()

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func _on_whisper_rate_timeout():
	whisperGauge.value += 1

func _on_whisper_cooldown_timeout():
	whisperGauge.value -= 1
