extends Node2D

#items


var draggable = false
var is_inside_dropable = false # Tracks if currently over *any* droppable cell
var current_hovered_cell = null # Tracks the specific cell that should show hover feedback
var offset: Vector2
var initialPos: Vector2
var is_placed = false # Flag to track if the item has been successfully placed
# var body_ref # Ensure this line is removed if it exists from old versions

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
			
			var target_body = null
			# Ensure $Area2D exists and is an Area2D node.
			# This assumes your item scene has a child Area2D node named "Area2D".
			# If it's named differently, adjust $Area2D accordingly.
			var overlapping_bodies = $Area2D.get_overlapping_bodies()
			
			for body in overlapping_bodies:
				if body.is_in_group("Dropable"):
					target_body = body # Found a droppable target
					break 
					
			if target_body:
				# Successfully dropped on a target
				current_hovered_cell = target_body # Update current_hovered_cell to the actual target
				is_inside_dropable = true # Update flag based on actual drop
				# Ensure the target cell is visually confirmed as hovered if not already
				if current_hovered_cell and current_hovered_cell.modulate != Color(Color.ALICE_BLUE):
					current_hovered_cell.modulate = Color(Color.ALICE_BLUE)

				tween.tween_property(self, "position", target_body.position, 0.2).set_ease(Tween.EASE_OUT)
				$NameLabel.visible = false
				$FrameCard.visible = false
				$EffectLabel.visible = false
				draggable = false # Disable dragging after successful drop
				is_placed = true # Mark as placed
			else:
				# No valid drop target found at the moment of release
				is_inside_dropable = false # Update flag
				tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
				$NameLabel.visible = true
				$FrameCard.visible = true
				$EffectLabel.visible = true
				# draggable remains true, is_placed remains false

func _on_area_2d_mouse_entered() -> void:
	if not Globals.is_dragging and not is_placed: # Only allow dragging if not already placed
		# Visual feedback for hover starts here
		# The actual drop logic is now more robust
		draggable =  true
		scale = Vector2(1.05,1.05)
	


func _on_area_2d_mouse_exited() -> void:
	if not Globals.is_dragging:
		draggable =  false
		scale = Vector2(1,1)


func _on_area_2d_body_entered(body: StaticBody2D) -> void:
	if body.is_in_group('Dropable') and not is_placed:
		if current_hovered_cell and current_hovered_cell != body:
			current_hovered_cell.modulate = Color(Color.CORNSILK) # Reset old one
		
		current_hovered_cell = body
		if current_hovered_cell: # Ensure it's not null before modulating
			current_hovered_cell.modulate = Color(Color.ALICE_BLUE) # Highlight new one
		
		is_inside_dropable = true 
		# print("Entered: ", body.name if body else "None", " | Current Hovered: ", current_hovered_cell.name if current_hovered_cell else "None")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('Dropable') and not is_placed:
		if current_hovered_cell == body:
			# This was the primary hovered cell, reset it
			if current_hovered_cell: # Ensure it's not null
				current_hovered_cell.modulate = Color(Color.CORNSILK)
			current_hovered_cell = null
			# is_inside_dropable will be re-evaluated below
		elif body is StaticBody2D and body.is_in_group('Dropable'): # Exited a droppable body that wasn't the primary one
			body.modulate = Color(Color.CORNSILK) # Ensure it's reset

		# After an exit, re-evaluate if still over any droppable cell
		var still_overlapping_droppable = false
		var new_hovered_candidate = null
		if $Area2D: # Check if $Area2D is valid and accessible
			var overlapping_bodies = $Area2D.get_overlapping_bodies()
			for overlapping_body in overlapping_bodies:
				if overlapping_body.is_in_group("Dropable"):
					still_overlapping_droppable = true
					new_hovered_candidate = overlapping_body # This is now the primary candidate
					break 
		
		is_inside_dropable = still_overlapping_droppable
		
		if current_hovered_cell != new_hovered_candidate:
			if current_hovered_cell: # If there was an old primary different from new one, reset it
				current_hovered_cell.modulate = Color(Color.CORNSILK)
			current_hovered_cell = new_hovered_candidate
			if current_hovered_cell: # If there's a new primary, highlight it
				current_hovered_cell.modulate = Color(Color.ALICE_BLUE)
		
		# print("Exited: ", body.name if body else "None", " | Still inside: ", is_inside_dropable, " | Current Hovered: ", current_hovered_cell.name if current_hovered_cell else "None")
