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
		$move/toHall.visible = true
		changecrsr_def()

# SCENE 5
func _ready() -> void:
	Input.set_custom_mouse_cursor(default_crsr)
	$fadein/AnimationPlayer.play("fadein")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Arvostus.playing:
		Arvostus.stop()
	if !SafeForNow.playing:
		SafeForNow.play()
	if BlastedHeath.playing:
		BlastedHeath.stop()

#BACK TO HALL
func _on_to_hall_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !Singleton.bedroomnightmaresaw:
			$fadeout.visible = true
			$fadeout/AnimationPlayer.play("fadeout")
			$stairsnoiseNormal.play()
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_stairsnoise_normal_finished() -> void:
	get_tree().change_scene_to_file(target_level)

# OBJECTS

#WINDOW ON THE LEFT
func _on_window_1_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The view from here is actually quite beautiful. There's the forest, the road, and the mountains off in the distance."
		dialoganim()
		$move/toHall.visible = false

#WINDOW ON THE RIGHT
func _on_window_2_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The moon is high up in the sky now. It's getting late."
		dialoganim()
		$move/toHall.visible = false

#CHAIR
func _on_chair_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The chair looks weird. One of the legs is broken. The wood is stained with ashes."
		dialoganim()
		$move/toHall.visible = false

#CIGARETTES
func _on_cigars_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Discarded bits of cigarettes. The smell of ash is strong."
		dialoganim()
		$move/toHall.visible = false

#PILE OF CLOTHES
func _on_pile_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "This is a little sad to look at. Some of these clothes don't appear to be his."
		dialoganim()
		$move/toHall.visible = false

#SOCKS
func _on_socks_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Scandalous. The socks are slightly stained with what appears to be dirt. There are also some blades of grass."
		dialoganim()
		$move/toHall.visible = false

#CLOTHES HANGERS
func _on_hangers_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Only three hangers despite all these clothes. How odd."
		dialoganim()
		$move/toHall.visible = false

#BED
func _on_bed_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The mattress is worn and old. The middle has sunk into what appears to be the shape of Reid's body."
		dialoganim()
		$move/toHall.visible = false

#CLOTHES ON BED
func _on_clothes_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "His work uniform. He was a stocker at some kind of warehouse. They fired him because he stopped going. He never returned the outfit."
		dialoganim()
		$move/toHall.visible = false

#PILLOW
func _on_pillow_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Many tears must have been shed here. There are also some stains of ash."
		dialoganim()
		$move/toHall.visible = false

#MOLD ON WALLS
func _on_mold_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Oh God... I'm surprised the roof hasn't fallen yet."
		dialoganim()
		$move/toHall.visible = false

#CARPET
func _on_carpet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Ash stains cover several parts of the carpet."
		dialoganim()
		$move/toHall.visible = false

#BOX WITH MEDICINE
func _on_box_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A small box with drawers. They are filled with medication, mostly for headaches and similar uses. None for whatever psychological issues he was having."
		dialoganim()
		$move/toHall.visible = false

#DIARY
func _on_diary_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		$move/toHall.visible = false
		if !Singleton.read_diary:
			$dialog/label.text = "It's Reid's diary. There is black goo coming out, and some of the pages and a part of the cover appear... Chewed. Like someone bit a chunk off of it. I really shouldn't look, but..."
			$dialog/close.visible = false
			$inspect/diaryArea/diaryTimer1.start()

func _on_diary_timer_1_timeout() -> void:
	$dialog/label.text = "Most of the older pages have been torn. Some... Eaten. It's alright. I would rather have him tell me about his past himself. The most recent ones appear intact. Let's see..."
	dialoganim()
	$inspect/diaryArea/diaryTimer2.start()
	SafeForNow.stop()
	SomethingsWrong.play()

func _on_diary_timer_2_timeout() -> void:
	$diary/page1.visible = true
	$dialog.visible = false
func _on_continue_1_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page1.visible = false
		$diary/page2.visible = true
func _on_continue_2_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page2.visible = false
		$diary/page3.visible = true
		SomethingsWrong.stop()
		BlastedHeath.play()
		Singleton.tension = true
func _on_continue_3_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page3.visible = false
		$diary/page4.visible = true
func _on_continue_4_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page4.visible = false
		$diary/page5.visible = true
func _on_continue_5_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page5.visible = false
		$diary/page6.visible = true
func _on_continue_6_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page6.visible = false
		$diary/page7.visible = true
		$thingNoise4.play()
func _on_clspclose_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$diary/page7.visible = false
		$dialog.visible = true
		$dialog/label.text = "There are no more entries after this-- ?!"
		dialoganim()
		$background.visible = false
		$backgroundNghtmr1.visible = true
		BlastedHeath.stop()
		ItsInTheWalls.play()
		$jumpscareTimer.start()
		$thingNoise1.play()
		$thingNoise2.play()
		$thingNoise3.play()

func _on_jumpscare_timer_timeout() -> void:
	$backgroundNghtmr1.visible = false
	$backgroundNghtmr2.visible = true
	$dialog/label.text = "I need to get out of here."
	dialoganim()
	$jumpscareTimer2.start()
	Singleton.bedroomnightmaresaw = true

func _on_jumpscare_timer_2_timeout() -> void:
	$fadeout.visible = true
	$fadeout/AnimationPlayer.play("fadeout")
	$stairsnoiseRun.play()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_stairsnoise_run_finished() -> void:
	get_tree().change_scene_to_file(target_level)
