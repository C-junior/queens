extends StaticBody2D


func _ready() -> void:
	modulate = Color(Color.CORNSILK)

func _process(delta: float) -> void:
	if Globals.is_dragging:
		visible =  true
	else:
		visible = false
