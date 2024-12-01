extends AudioStreamPlayer

@export var playlist : Array[AudioStreamMP3]
var audioNo = 0

func _ready() -> void:
	stream = playlist[0]
	play()

func _on_finished() -> void:
	audioNo += 1
	if audioNo > playlist.size()-1:
		audioNo = 0
	else:
		stream = playlist[audioNo]
		play()
