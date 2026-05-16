extends Area2D

@export var message = ""
@export var duration = 3.0
@export var blocking = false
@export var one_shot = true

var already_triggered = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body) -> void:
	if one_shot and already_triggered:
		return
	already_triggered = true
	var mascot: Control = get_node("/root/Main/UILayer/Mascot")
	if mascot:
		mascot.speak(message, duration, blocking)
