class_name TryDisplay extends HBoxContainer


static var scene : PackedScene = load("res://scenes/ui/try_display.tscn")
static func new_secen() -> TryDisplay:
	var scene : TryDisplay = scene.instantiate()
	return scene


func set_try(try_number: int, score: float) -> void:
	$Label.text = "Try#%d : "%try_number
	$Value.text = str(score)
