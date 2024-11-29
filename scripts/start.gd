extends Node2D
var visible_characters = 0
@export var target_level : PackedScene

func _ready() -> void:
	Arvostus.stop()
	SomethingsWrong.stop()
	SafeForNow.stop()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func animplay():
	$AnimationPlayer.play("typewriter")

func _on_initial_timeout() -> void:
	$label.visible = true
	animplay()
	$carsound.play()
	$one.start()
	$img1.visible = true

func _process(delta: float) -> void:
	if visible_characters != $label.visible_characters:
		visible_characters = $label.visible_characters
		$typenoise.play()

func _on_one_timeout() -> void:
	$label.visible = false
	$break1.start()

func _on_break_1_timeout() -> void:
	$label.visible = true
	$label.text = "The drive was quiet. He was alone. He needed to do this alone, for his and his patient's sakes."
	animplay()
	$two.start()
	$img1.visible = false
	$img2.visible = true

func _on_two_timeout() -> void:
	$label.visible = false
	$break2.start()

func _on_break_2_timeout() -> void:
	$label.visible = true
	$label.text = "The lonely house up in the hill greeted him with a whispering breeze as he stopped his car."
	animplay()
	$carsound.stop()
	$cardoor1.play()
	$three.start()
	$img2.visible = false
	$img3.visible = true
func _on_cardoor_1_finished() -> void:
	$cardoor2.play()
	$ambience.play()

func _on_three_timeout() -> void:
	$label.visible = false
	$break3.start()
	$img3.visible = false

func _on_break_3_timeout() -> void:
	$label.visible = true
	$label.text = "A strange, sour, undescribable smell reached him as he began his steps towards the house."
	animplay()
	$four.start()
	$stepsdirt.play()

func _on_four_timeout() -> void:
	$label.text = "He hesitates, slightly, with each step. The smell grows stronger. The house stares at him through darkened windows."
	animplay()
	$five.start()

func _on_five_timeout() -> void:
	$label.visible = false
	$break4.start()
	$stepsdirt.stop()
	$stepswood.play()

func _on_break_4_timeout() -> void:
	$label.visible = true
	$label.text = "The door creaks open, sending echoes down the halls as he steps inside."
	animplay()
	$door.play()
	$six.start()
	$img4.visible = true

func _on_six_timeout() -> void:
	$finalbreak.start()
	$AnimationPlayer2.play("audiofadeout")
	$AnimationPlayer3.play("imgfadeout")
	$AnimationPlayer4.play("textfadeout")

func _on_finalbreak_timeout() -> void:
	get_tree().change_scene_to_packed(target_level)
