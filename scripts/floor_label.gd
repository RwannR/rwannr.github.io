extends Label

var floor_names = {
	"f0": "RDC",
	"f1": "Etage 1",
	"f2": "Etage 2",
	"roof": "Rooftop"
}

func _ready() -> void:
	text = floor_names.get(GameManager.current_floor, "???")
