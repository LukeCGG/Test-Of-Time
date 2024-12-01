extends CanvasLayer

@warning_ignore("unused_signal") signal loading_screen_had_full_coverage

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var progressBar : ProgressBar = $Control/ProgressBar
	
func _update_progress_bar(new_value: float):
	progressBar.set_value_no_signal(new_value * 100)
	
func _start_outro_animation():
	await Signal(animationPlayer, "animation_finished")
	animationPlayer.play("end_load")
	await Signal(animationPlayer, "animation_finished")
	self.queue_free()
