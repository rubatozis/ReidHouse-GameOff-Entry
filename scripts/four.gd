extends Node2D

var visible_characters = 0

var detail_selected = false

var the_end = false

var slot1_filled = false
var slot2_filled = false
var slot3_filled = false

var default_crsr = preload("res://assets/art/cursors1.png")
var inspect_crsr = preload("res://assets/art/cursors2.png")
var hand_crsr = preload("res://assets/art/cursors3.png")
var walk_crsr = preload("res://assets/art/cursors4.png")

@export_file("*.tscn") var target_level: String

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

# DIALOG ANIMATION
func dialoganim():
	$dialog/dialoganim.play("typewriter2")

# DIALOG TYPE NOISE
func _process(delta: float) -> void:
	if visible_characters != $dialog/label.visible_characters:
		visible_characters = $dialog/label.visible_characters
		$typenoise.play()

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
		$inspect/boxesArea.visible = true

# SCENE FOUR
func _ready() -> void:
	if ItsInTheWalls.playing:
		ItsInTheWalls.stop()
	if Arvostus.playing:
		Arvostus.stop()
	TimeWhistle.play()
	Input.set_custom_mouse_cursor(default_crsr)
	$fadein/AnimationPlayer.play("fadein")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# CLOSED DOOR
func _on_door_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$backgroundOne.visible = false
		$backgroundTwo.visible = true
		$backgroundOne/doorNoise.play()
		changecrsr_walk()

# OPEN DOOR
func _on_dooropen_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$fadeout.visible = true
		$fadeout/AnimationPlayer.play("fadeout")
		$fadeout/fadeoutTimer.start()
		$walkNoise.play()
# INTO THE BASEMENT
func _on_fadeout_timer_timeout() -> void:
	if !the_end:
		$fadein/AnimationPlayer.play("fadein")
		$fadeout.visible = false
		$backgroundTwo.visible = false
		$backgroundThree.visible = true
		$inspect.visible = true
		$crowbar.visible = true
	else:
		get_tree().change_scene_to_file(target_level)


# OBJECTS

#FURNACE
func _on_furnace_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "An old, strange model of a furnace. It's stuck and can't be opened."
		dialoganim()
		$inspect/boxesArea.visible = false

#FURNACE CHIMNEY
func _on_chimney_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "That must be the chimney I saw on the roof from outside, but... It makes no sense with the layout..."
		dialoganim()
		$inspect/boxesArea.visible = false

#WELL
func _on_well_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's a well. I don't want to look into it."
		dialoganim()
		$inspect/boxesArea.visible = false

#VEINS
func _on_veins_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "..."
		dialoganim()
		$inspect/boxesArea.visible = false

#FALLEN CHAIR
func _on_chair_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A fallen chair. It's stained with some kind of dark liquid I don't want to stare at."
		dialoganim()
		$inspect/boxesArea.visible = false

#ORGANS ON TABLE
func _on_organs_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "I don't even want to think about what he was doing with those..."
		dialoganim()
		$inspect/boxesArea.visible = false

#SALT JARS
func _on_salts_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Some pale-colored powders. These must be the salts he was referring to."
		dialoganim()
		$inspect/boxesArea.visible = false

#SHELF
func _on_shelf_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's completely empty."
		dialoganim()
		$inspect/boxesArea.visible = false

#BOXES
func _on_boxes_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Cardboard boxes containing things you'd usually keep in the basement. One of them is labeled 'Christmas deco'."
		dialoganim()
		$inspect/boxesArea.visible = false

#DEAD RATS
func _on_rats_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's been dead for a while."
		dialoganim()
		$inspect/boxesArea.visible = false

#STAIRCASE
func _on_stairs_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "I can see from down here that the entrance has been blocked with wooden planks. Hopefully there's something here that I can use to pull them off."
		dialoganim()
		$inspect/boxesArea.visible = false





#CROWBAR ITEM
func _on_crowbar_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and !Singleton.crowbar_picked and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/close.visible = false
		$dialog/label.text = "I found a crowbar."
		dialoganim()
		$inspect/boxesArea.visible = false
		$crowbar/Timer2.start()

# WELL CUTSCENE

func _on_timer_2_timeout() -> void:
	$dialog/label.text = "As I get up, I can't help but glance down into the well... Then stare at it."
	dialoganim()
	$crowbar/Timer3.start()
	TimeWhistle.volume_db = 2
	changecrsr_def()

func _on_timer_3_timeout() -> void:
	$dialog.visible = false
	$closeupWell.visible = true
	TimeWhistle.volume_db = 4
	$closeupWell/wellTimer1.start()
	$wellMusic.play()
	
func _on_well_timer_1_timeout() -> void:
	$closeupWell.visible = false
	TimeWhistle.volume_db = 6
	$closeupWell2.visible = true
	$closeupWell2/wellTimer2.start()
	$wellMusic.volume_db = -8

func _on_well_timer_2_timeout() -> void:
	$closeupWell2.visible = false
	TimeWhistle.volume_db = 8
	$closeupWell3.visible = true
	$closeupWell3/wellTimer3.start()
	$wellMusic.volume_db = -6

func _on_well_timer_3_timeout() -> void:
	$closeupWell3.visible = false
	TimeWhistle.volume_db = 10
	$wellMusic.volume_db = -4
	$closeupWell4.visible = true
	$closeupWell4/wellTimer4.start()
	$inventory.visible = false
	$crowbar.visible = false
	$dialog.visible = true
	$dialog/label.text = "..."
	dialoganim()

#CREATURE CUTSCENE

func _on_well_timer_4_timeout() -> void:
	$closeupWell4.visible = false
	TimeWhistle.volume_db = 14
	$wellMusic.volume_db = -2
	$CreatureOne.visible = true
	$dialog/label.text = "It's like the darkness took over the room..."
	dialoganim()
	$CreatureOne/finalTimer1.start()
	$thingNoise6.play()

func _on_final_timer_1_timeout() -> void:
	TimeWhistle.volume_db = 18
	$wellMusic.volume_db = 0
	$dialog/label.text = "I can still make it to the door. Just need to be careful about the stairs..."
	dialoganim()
	$walkNoise.play()
	$CreatureOne/finalTimer2.start()

func _on_final_timer_2_timeout() -> void:
	$wellMusic.volume_db = 2
	$dialog/label.text = "..."
	dialoganim()
	$thingNoise1.play()
	$CreatureOne/finalTimer3.start()

func _on_final_timer_3_timeout() -> void:
	$dialog/label.text = "...It's here. It's here with me."
	dialoganim()
	$CreatureOne/finalTimer4.start()
	$wellMusic.volume_db = 4

func _on_final_timer_4_timeout() -> void:
	$CreatureOne.visible = false
	$CreatureTwo.visible = true
	$dialog/label.text = "..."
	dialoganim()
	$CreatureTwo/finalTimer5.start()
	$thingNoise5.play()
	$wellMusic.volume_db = 6

func _on_final_timer_5_timeout() -> void:
	$dialog/label.text = "...It was here with him too. It..."
	dialoganim()
	$CreatureTwo/finalTimer6.start()
	$wellMusic.volume_db = 8
	$thingNoise8.play()

func _on_final_timer_6_timeout() -> void:
	$thingNoise1.play()
	$dialog/label.text = "I need to go."
	dialoganim()
	$CreatureTwo.visible = false
	$CreatureThree.visible = true
	$CreatureThree/finalTimer7.start()
	$thingNoise7.play()

func _on_final_timer_7_timeout() -> void:
	$dialog.visible = false
	$stairsNoise.play()
	$thingNoise4.play()

func _on_stairs_noise_finished() -> void:
	$woodNoise1.play()
	$thingNoise2.play()

func _on_wood_noise_1_finished() -> void:
	$woodNoise2.play()

func _on_wood_noise_2_finished() -> void:
	$woodNoise3.play()
	$thingNoise3.play()
	$CreatureThree/finalTimer8.start()

func _on_final_timer_8_timeout() -> void:
	$doorNoise2.play()
	$fadeout.visible = true
	$fadeout/AnimationPlayer.play("fadeout")
	$fadeout/fadeoutTimer.start()
	the_end = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
