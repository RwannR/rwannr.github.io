extends Node

signal vigilance_changed(new_value)
signal inventory_changed
signal f0_event_changed(event_type)

var current_floor = "f0"
var player_spawn_x = 200.0
var quest_data = {}
var vigilance = 50
var game_mode = "training"
var inventory = []
var player_name = "Employé"
var player_skin = "male"
var picked_items = []
var triggered_npcs = []

# Timer partagé peu importe l'étage pour porte et visiteur
var f0_event_triggered = false
var f0_event_type = ""
var f0_event_timer = 0.0
var f0_event_delay = 0.0

func _ready():
	pass

func _schedule_fo_event():
	if f0_event_triggered:
		return
	f0_event_delay = randf_range(15.0, 40.0)
	f0_event_timer = 0.0

func _process(delta):
	if f0_event_triggered:
		return
	
	f0_event_timer += delta
	if f0_event_timer >= f0_event_delay:
		f0_event_triggered = true
		# Choisis aléatoirement entre porte et visiteur
		if randi() % 2 == 0:
			f0_event_type = "door"
		else:
			f0_event_type = "visitor"
		f0_event_changed.emit(f0_event_type)

func change_floor(target_floor, spawn_x) -> void:
	current_floor = target_floor
	player_spawn_x = spawn_x
	call_deferred("_do_change_scene", target_floor)

func _do_change_scene(target_floor) -> void:
	get_tree().change_scene_to_file("res://scenes/" + target_floor + ".tscn")

func add_vigilance(amount):
	if game_mode == "game":
		vigilance += amount
	else:
		vigilance = clamp(vigilance + amount, 0, 100)
	vigilance_changed.emit(vigilance)

func remove_vigilance(amount):
	if game_mode == "game":
		vigilance = max(vigilance - amount, 0)
	else:
		vigilance = clamp(vigilance - amount, 0, 100)
	vigilance_changed.emit(vigilance)

func add_item(item_id, item_name, item_description = "", item_icon = ""):
	inventory.append({
		"id": item_id,
		"name": item_name,
		"description": item_description,
		"icon": item_icon
	})
	inventory_changed.emit()

func remove_item(item_id):
	for i in range(inventory.size()):
		if inventory[i].id == item_id:
			inventory.remove_at(i)
			inventory_changed.emit()
			return true
	return false

func has_item(item_id):
	for item in inventory:
		if item.id == item_id:
			return true
	return false

func reset_f0_event():
	f0_event_triggered = false
	f0_event_type = ""
	f0_event_timer = 0.0
	f0_event_delay = randf_range(30.0, 60.0)
