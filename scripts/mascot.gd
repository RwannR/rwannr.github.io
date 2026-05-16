extends Control

@onready var sprite: Node2D = $Body
@onready var speech_bubble: PanelContainer = $SpeechBubble
@onready var message_label: Label = $SpeechBubble/MarginContainer/Message
@onready var speech_timer: Timer = $SpeechTimer

var is_speaking = false
var block_player = false

func _ready() -> void:
	speech_bubble.visible = false
	speech_timer.timeout.connect(_on_timer_timeout)

func speak(text, duration = 5.0, blocking = false) -> void:
	message_label.text = text
	speech_bubble.visible = true
	is_speaking = true
	block_player = blocking
	speech_timer.start(duration)
	if blocking:
		_set_player_frozen(true)

func _on_timer_timeout() -> void:
	speech_bubble.visible = false
	is_speaking = false
	if block_player:
		_set_player_frozen(false)
		block_player = false

func _set_player_frozen(frozen):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.frozen = frozen
