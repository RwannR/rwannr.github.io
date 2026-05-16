extends Area2D

@export var target_floor = ""
@export var spawn_x = 200.0
@export var goes_up = true

@onready var sprite = $Sprite2D

var tex_up = preload("res://assets/sprites/stairs_up.png")
var tex_down = preload("res://assets/sprites/stairs_down.png")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if goes_up:
		sprite.texture = tex_up
	else:
		sprite.texture = tex_down

func _on_body_entered(body) -> void:
	if body is CharacterBody2D:
		GameManager.change_floor(target_floor, spawn_x)
