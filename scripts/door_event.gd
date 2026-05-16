extends Area2D

@export var time_limit = 20.0
@export var quest_id = "q_door"

@onready var alert_timer = $AlertTimer
@onready var timer_label = $TimerLabel
@onready var sprite = $Sprite2D

var is_open = false
var already_triggered = false
var time_remaining = 0.0

func _ready():
	timer_label.visible = false
	sprite.visible = false

	GameManager.f0_event_changed.connect(_on_f0_event)

	# Si l'événement a déjà été déclenché avant qu'on arrive à f0
	if GameManager.f0_event_triggered and GameManager.f0_event_type == "door":
		_open_door()

func _on_f0_event(event_type):
	if event_type == "door" and not already_triggered:
		_open_door()

func _open_door():
	if already_triggered:
		return
	
	is_open = true
	sprite.visible = true
	timer_label.visible = true
	time_remaining = time_limit
	alert_timer.start(time_limit)
	
	var mascot_nodes = get_tree().get_nodes_in_group("mascot")
	if mascot_nodes.size() > 0:
		mascot_nodes[0].speak("Attention ! La porte d'entrée est restée ouverte ! Allez la fermer !", 4.0, false)
	
func _process(delta):
	if is_open:
		time_remaining -= delta
		timer_label.text = str(int(time_remaining)) + "s"

		if time_remaining <= 5:
			timer_label.modulate = Color(1, 0.3, 0.3)
		else:
			timer_label.modulate = Color(1, 1, 1)
		 
		if time_remaining <= 0:
			_time_expired()

func interact():
	if not is_open:
		return
	_close_door()

func _close_door():
	is_open = false
	already_triggered = true
	alert_timer.stop()
	timer_label.visible = false
	sprite.visible = false

	GameManager.add_vigilance(15)
	QuestManager.complete_quest(quest_id)

	var mascot_nodes = get_tree().get_nodes_in_group("mascot")
	if mascot_nodes.size() > 0:
		mascot_nodes[0].speak("Bien joué ! Vous avez sécurisé l'entrée.", 3.0, false)
	
	await get_tree().create_timer(10.0).timeout
	already_triggered = false
	GameManager.reset_f0_event()

func _time_expired():
	is_open = false
	already_triggered = true
	timer_label.visible = false

	GameManager.remove_vigilance(15)

	var mascot_nodes = get_tree().get_nodes_in_group("mascot")
	if mascot_nodes.size() > 0:
		mascot_nodes[0].speak("Trop tard ! Un inconnu est entré dans les locaux.", 5.0, true)
	
	GameManager.reset_f0_event()
