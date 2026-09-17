extends Node

enum MusicTracks {
	TITLE,
	MAP,
	COMBAT,
	BOSS,
	VICTORY,
	DEFEAT
}
@export var tracks: Dictionary[MusicTracks, AudioStreamPlayer] = {
	MusicTracks.TITLE: null,
	MusicTracks.MAP: null,
	MusicTracks.COMBAT: null,
	MusicTracks.BOSS: null,
	MusicTracks.VICTORY: null,
	MusicTracks.DEFEAT: null
}
@export var fade_duration: float = 1
var current_track: AudioStreamPlayer = null

func _fade_out(track: MusicTracks):
	var soundtrack: AudioStreamPlayer = tracks[track]
	var tween = create_tween()
	tween.tween_property(soundtrack, "volume_db", -30, fade_duration)
	tween.tween_callback(soundtrack.stop)

func _fade_in(track: MusicTracks):
	var soundtrack: AudioStreamPlayer = tracks[track]
	var tween = create_tween()
	soundtrack.volume_db = -30
	tween.tween_callback(soundtrack.play)
	tween.tween_property(soundtrack, "volume_db", 0, fade_duration * 0.5)

func change_soundtrack(track_to_play: MusicTracks):
	if tracks[track_to_play] == current_track:
		return
	if not tracks.has(track_to_play):
		return
	if tracks[track_to_play] == null:
		return
	
	if current_track == null:
		current_track = tracks[track_to_play]
		current_track.play()
		return
	
	_fade_out(tracks.find_key(current_track))
	await get_tree().create_timer(0.5).timeout
	_fade_in(track_to_play)
	current_track = tracks[track_to_play]
