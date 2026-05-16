extends Area2D

@export var tip_title = ""
@export var tip_content = ""
@export var opens_browser = false
@export var browser_group = "browser_window"
@export var event_id = ""

func interact():
	if opens_browser:
		var nodes = get_tree().get_nodes_in_group(browser_group)
		if nodes.size() > 0:
			nodes[0].open_window()
	elif event_id != "":
		_trigger_event()
	elif tip_title != "":
		var nodes = get_tree().get_nodes_in_group("popup_tip")
		if nodes.size() > 0:
			nodes[0].show_tip(tip_title, tip_content)

func _trigger_event():
	var file = FileAccess.open("res://data/events.json", FileAccess.READ)
	if !file:
		return
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result != OK:
		return
	
	var events =  json.data
	if not events.has(event_id):
		return
	
	var event = events[event_id]
	var nodes = get_tree().get_nodes_in_group("choice_dialog")
	if nodes.size() > 0:
		nodes[0].show_dialog(event.description, event.choices, event.quest_id, event)
