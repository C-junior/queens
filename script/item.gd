extends Node2D

#items


var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2

func _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed('click'):
			offset = get_global_mouse_position() - global_position
			Globals.is_dragging = true
			initialPos = global_position
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			Globals.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropable:
				tween.tween_property(self, "position", body_ref.position,0.2).set_ease(Tween.EASE_OUT)
				$NameLabel.visible = false
				$FrameCard.visible = false
				$EffectLabel.visible = false
				
			else:
				tween.tween_property(self, "global_position", initialPos ,0.2).set_ease(Tween.EASE_OUT)
				$NameLabel.visible = true
				$FrameCard.visible = true
				$EffectLabel.visible = true
func _on_area_2d_mouse_entered() -> void:
	if not Globals.is_dragging:
		draggable =  true
		scale = Vector2(1.05,1.05)
	


func _on_area_2d_mouse_exited() -> void:
	if not Globals.is_dragging:
		draggable =  false
		scale = Vector2(1,1)


func _on_area_2d_body_entered(body: StaticBody2D) -> void:
	if body.is_in_group('Dropable'):
		is_inside_dropable = true
		body.modulate = Color(Color.ALICE_BLUE)
		body_ref = body
		print(body_ref)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('Dropable'):
		is_inside_dropable = false
		body.modulate = Color(Color.CORNSILK)
