extends Sprite2D

@export var poster_id = ""
@export var max_width = 64

var posters_data = []

func _ready() -> void:
	_load_posters()
	_apply_poster()

func _load_posters():
	var file = FileAccess.open("res://data/posters.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()
		if result == OK:
			posters_data = json.data.posters

func _apply_poster():
	for poster in posters_data:
		if poster.id == poster_id:
			if ResourceLoader.exists(poster.image_path):
				var tex = load(poster.image_path)
				texture = tex
				var img_size = tex.get_size()
				var ratio = img_size.y / img_size.x
				scale = Vector2(float(max_width) / img_size.x, float(max_width) / img_size.x * ratio)
			else:
				_create_placeholder(poster.description)
			return
	
	_create_placeholder("Poster: " + poster_id)

func _create_placeholder(_text):
	# Crée un placeholder gris
	var img = Image.create(max_width, int(max_width * 0.75), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.3, 0.35))
	texture = ImageTexture.create_from_image(img)
