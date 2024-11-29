extends Node2D

var dragging = false
var picked_up = false
var drop_location_id = 0
var drop_location
var dropped = false
var timer_off = true
var hand_crsr = preload("res://assets/art/cursors3.png")
@export var item_id = 1
@export var inventory_icon = Sprite2D

func _ready() -> void:
	inventory_icon.visible = false

func _physics_process(delta: float) -> void:
	if dragging:
		global_position = lerp(global_position, get_global_mouse_position(), 30 * delta)
		dropped = false
		Input.set_custom_mouse_cursor(hand_crsr)
	else:
		if picked_up:
			if !dropped:
				drop_location = get_parent().set_drop_location(self)
				if timer_off:
					$Timer.start()
					timer_off = false
			global_position = lerp(global_position, drop_location, 20 * delta)
		inventory_icon.visible = true

func _on_item_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Singleton.roach_int:
		if !picked_up and !dragging:
			global_position = get_parent().choose_slot(self)
			z_index = 10
			picked_up = true
			Singleton.roach_picked = true
		else:
			if event.pressed:
				dragging = true
			else:
				dragging = false
			$sprite_world.visible = false

func _on_timer_timeout() -> void:
	dropped = true
	timer_off = true
