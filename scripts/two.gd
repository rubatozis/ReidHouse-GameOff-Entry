extends Node2D

var visible_characters = 0

var detail_selected = false
var lights_on = false

var slot1_filled = false
var slot2_filled = false
var slot3_filled = false

var default_crsr = preload("res://assets/art/cursors1.png")
var inspect_crsr = preload("res://assets/art/cursors2.png")
var hand_crsr = preload("res://assets/art/cursors3.png")
var walk_crsr = preload("res://assets/art/cursors4.png")

@export_file("*.tscn") var target_level1: String
@export_file("*.tscn") var target_level2: String

# MOUSE STUFF
func changecrsr_insp():
	if !detail_selected:
		Input.set_custom_mouse_cursor(inspect_crsr)

func changecrsr_def():
	if !detail_selected:
		Input.set_custom_mouse_cursor(default_crsr)

func changecrsr_hand():
	if !detail_selected:
		Input.set_custom_mouse_cursor(hand_crsr)

func changecrsr_walk():
	if !detail_selected:
		Input.set_custom_mouse_cursor(walk_crsr)

# Inventory things
func fill_slot(slot):
	match slot:
		1:	slot1_filled = true
		2:	slot2_filled = true
		3:	slot3_filled = true

func empty_slot(slot):
	match slot:
		1:	slot1_filled = false
		2:	slot2_filled = false
		3:	slot3_filled = false

func choose_slot(item):
	var chosen_slot = 1
	if !slot1_filled:
		chosen_slot = $inventory/slot1.global_position
		slot1_filled = true
		item.drop_location_id = 1
	elif !slot2_filled:
		chosen_slot = $inventory/slot2.global_position
		slot1_filled = true
		item.drop_location_id = 2
	elif !slot3_filled:
		chosen_slot = $inventory/slot3.global_position
		slot1_filled = true
		item.drop_location_id = 3
	return chosen_slot

func set_drop_location(item):
	var drop_location
	match item.drop_location_id:
		0: drop_location = item.global_position
		1: drop_location = $inventory/slot1.global_position
		2: drop_location = $inventory/slot2.global_position
		3: drop_location = $inventory/slot3.global_position
	return drop_location


func _on_slot_1_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and !slot1_filled:
		empty_slot(area.get_parent().drop_location_id)
		area.get_parent().drop_location_id = 1
		fill_slot(area.get_parent().drop_location_id)


func _on_slot_2_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and !slot2_filled:
		empty_slot(area.get_parent().drop_location_id)
		area.get_parent().drop_location_id = 2
		fill_slot(area.get_parent().drop_location_id)


func _on_slot_3_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and !slot3_filled:
		empty_slot(area.get_parent().drop_location_id)
		area.get_parent().drop_location_id = 3
		fill_slot(area.get_parent().drop_location_id)

# DIALOG CLOSE BUTTON
func _on_close_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = false
		detail_selected = false
		changecrsr_def()

# DIALOG ANIMATION
func dialoganim():
	$dialog/dialoganim.play("typewriter2")

# DIALOG TYPE NOISE
func _process(delta: float) -> void:
	if visible_characters != $dialog/label.visible_characters:
		visible_characters = $dialog/label.visible_characters
		$typenoise.play()

#SCENE TWO
func _ready() -> void:
	Input.set_custom_mouse_cursor(default_crsr)
	$fadein/AnimationPlayer.play("fadein")
	$walkNoise.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if !Singleton.bedroomnightmaresaw:
		if !Singleton.lights_on:
			$backgroundDark.visible = true
			$backgroundLight.visible = false
		else:
			$backgroundDark.visible = false
			$backgroundLight.visible = true
	else:
		$backgroundDark.visible = false
		$backgroundLight.visible = false
		$backgroundNghtmr.visible = true
		$thingNoise1.play()
		$thingNoise2.play()
		if Arvostus.playing:
			Arvostus.stop()
		if SomethingsWrong.playing:
			SomethingsWrong.stop()
		if BlastedHeath.playing:
			BlastedHeath.stop()
		if !ItsInTheWalls.playing:
			ItsInTheWalls.play()
		$dialog.visible = true
		dialoganim()
		$dialog/label.text = "Oh God..."
		detail_selected = true
		$inspect.visible = false
		Singleton.hallnightmare = true
	if !Singleton.roach_used:
		if !Singleton.roach_picked || !slot1_filled:
			$roach/sprite_world.visible = true
			$roach/roachArea.visible = true
	else:
		$roach.visible = false

#MOVE BACK TO LIVING ROOM
func _on_right_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file(target_level1)

#MOVE TO BEDROOM
func _on_to_bedroom_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !Singleton.notice1read:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "I should check this entire floor first."
			dialoganim()
		else:
			if !Singleton.hole_anim:
				$dialog.visible = true
				detail_selected = true
				$dialog/label.text = "Did I check this hallway at all? There could be something."
				dialoganim()
			else:
				if !Singleton.bedroomnightmaresaw:
					$fadeout.visible = true
					$fadeout/AnimationPlayer.play("fadeout")
					$stairsNoise.play()
					Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
				else:
					$dialog.visible = true
					detail_selected = true
					$dialog/label.text = "I'm not going back up. No way."
					dialoganim()
func _on_stairs_noise_finished() -> void:
	get_tree().change_scene_to_file(target_level2)


# OBJECTS

#COUNTER, I THINK THATS WHAT ITS CALLED
func _on_counter_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		$dialog/label.text = "The wood is stained with soil and is covered in dust. The drawers are mostly empty except for a small gardening shovel."
		dialoganim()
		detail_selected = true

#FLOWER VASE
func _on_vase_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		$dialog/label.text = "The vase is dirty. There is a small sprout inside, completely wilted. Reid told me he wasn't good at taking care of living things."
		dialoganim()
		detail_selected = true

#WINDOW
func _on_window_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		$dialog/label.text = "The cicadas are singing in the grass outside."
		dialoganim()
		detail_selected = true

#RAT WALL HOLE THING
func _on_hole_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		dialoganim()
		detail_selected = true
		if !Singleton.hole_anim:
			if !Singleton.roach_int:
				$dialog/label.text = "Something moves softly in the dark. There's also air coming out -- like... Breathing. Given the state of this house, anything living in there must be starving. Though... There is a dead cockroach right beside it."
				Singleton.roach_int = true
			else:
				if !Singleton.roach_picked:
					$dialog/label.text = "There is a dead cockroach right beside it. It could've come out and eaten it at any time."
				else:
					$dialog/label.text = "I could put the roach here to confirm... Confirm what? It's probably just a rat. It can't be anything else."
		else:
			$dialog/label.text = "It just left a bunch of black goo behind."
			$inspect/holeArea/holeTimer3.start()
			$dialog/close.visible = false
func _on_hole_timer_3_timeout() -> void:
	$dialog.visible = false
	$closeupholeStatic2.visible = true
	$move/toBedroom.visible = false
	$dialog/close.visible = true
func _on_clspclose_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$closeupholeStatic2.visible = false
		detail_selected = false
		$move/toBedroom.visible = true

func _on_hole_area_area_entered(area: Area2D) -> void:
	if !detail_selected and area.is_in_group("item"):
		if area.get_parent().item_id == 2:
			Singleton.roach_used = true
			empty_slot(area.get_parent().drop_location_id)
			area.get_parent().queue_free()
			Input.set_custom_mouse_cursor(default_crsr)
			$dialog.visible = true
			$dialog/label.text = "I placed the roach at the mouth of the hole."
			$dialog/close.visible = false
			dialoganim()
			detail_selected = true
			$inspect/holeArea/holeTimer.start()
func _on_hole_timer_timeout() -> void:
	$closeupholeStatic1.visible = true
	$dialog.visible = false
	$inspect/holeArea/holeTimer2.start()
func _on_hole_timer_2_timeout() -> void:
	$closeupholeStatic1.visible = false
	$closeupholeStaticB.visible = true
	$inspect/holeArea/holeTimerB.start()
func _on_hole_timer_b_timeout() -> void:
	Singleton.tension = true
	if Arvostus.playing:
		Arvostus.stop()
	if !BlastedHeath.playing:
		BlastedHeath.play()
	if SafeForNow.playing:
		SafeForNow.stop()
	$holeanimSound.play()
	$closeupholeStaticB.visible = false
	$closeupholeAnim.visible = true
	$closeupholeAnim.play("default")
func _on_closeuphole_anim_animation_finished() -> void:
	$holeanimSound.stop()
	$closeupholeAnim.visible = false
	$dialog.visible = true
	$dialog/close.visible = true
	dialoganim()
	$dialog/label.text = "What the hell?!"
	Singleton.hole_anim = true


#WALL
func _on_wallhole_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		$dialog/label.text = "There's a gap here, but there's only darkness inside. I don't want to stare at it for too long."
		dialoganim()
		detail_selected = true

#ROACH ITEM
func _on_roach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !Singleton.roach_picked and !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		dialoganim()
		detail_selected = true
		if Singleton.roach_int:
			$dialog/label.text = "...I can't believe I'm holding this thing."
		else:
			$dialog/label.text = "I don't want to pick that up."
