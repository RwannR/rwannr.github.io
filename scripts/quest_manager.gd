extends Node

signal quest_updated(quest_id)
signal quest_completed(quest_id)

var quests = {}

func _ready() -> void:
	_load_quests()

func _load_quests():
	var file = FileAccess.open("res://data/quests.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()
		if result == OK:
			for quest in json.data:
				quest.status = "locked"
				quests[quest.id] = quest
	
	# Débloque les quêtes auto-actives
	for quest in quests.values():
		if quest.has("auto_active") && quest.auto_active:
			quest.status = "active"
	
	# Débloque la première quête dans tous les cas
	if quests.has("q1"):
		quests["q1"].status = "active"

func get_quest(quest_id) -> Dictionary:
	if quests.has(quest_id):
		return quests[quest_id]
	return {}

func get_active_quests() -> Array:
	var result = []
	for quest in quests.values():
		if quest.status == "active":
			result.append(quest)
	return result

func get_completed_quests() -> Array:
	var result = []
	for quest in quests.values():
		if quest.status == "completed":
			result.append(quest)
	return result

func complete_quest(quest_id):
	var quest = get_quest(quest_id)
	if quest.is_empty() || quest.status != "active":
		return
	
	quest.status = "completed"
	quest_completed.emit(quest_id)

	if quest.has("unlocks"):
		for next_id in quest.unlocks:
			if quests.has(next_id):
				quests[next_id].status = "active"
				quest_updated.emit(next_id)
