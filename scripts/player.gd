extends CharacterBody2D

var speed = 200.0
var gravity = 800.0
var jump_force = -350.0

var frozen = false
var nearest_interactable = null

@onready var body = $Body
@onready var anim = $AnimationPlayer
@onready var interaction_zone = $InteractionZone

func _ready():
	global_position.x = GameManager.player_spawn_x
	
	# Charge le skin
	if GameManager.player_skin == "female":
		var female_head = load("res://assets/sprites/character/body_head_female.png")
		$Body/Head.texture = female_head

func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		anim.play("idle")
		move_and_slide()
		return
	
	# Gravité
	velocity.y += gravity * delta

	# Saut
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_force
	
	# Déplacement horizontal
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Flip du personnage
	if direction != 0:
		body.scale.x = abs(body.scale.x) if direction > 0 else -abs(body.scale.x)
	
	# Animations
	if not is_on_floor():
		anim.play("idle")
	elif direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")
	
	_update_nearest_interactable()
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()

func _try_interact():
	if nearest_interactable and nearest_interactable.has_method("interact"):
		nearest_interactable.interact()

func _update_nearest_interactable():
	var areas = interaction_zone.get_overlapping_areas()
	if areas.is_empty():
		nearest_interactable = null
		return
	var closest = null
	var closest_dist = INF
	for area in areas:
		var dist = global_position.distance_to(area.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = area
	nearest_interactable = closest
