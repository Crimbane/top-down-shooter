extends Node

@onready var musicPlayer: AudioStreamPlayer = $"Music Player"

@export var menuMusic: AudioStream
@export var gameMusic: AudioStream
@export var gameMusic2: AudioStream
@export var gameMusic3: AudioStream
@export var creditsMusic: AudioStream

var gameMusicTracks: Array[AudioStream] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicPlayer.finished.connect(onGameMusicFinished)
	#playMenuMusic()
	gameMusicTracks= [gameMusic, gameMusic2, gameMusic3]

func stopMusic():
	musicPlayer.stop()
	musicPlayer.stream = null

func playMenuMusic():
	musicPlayer.pitch_scale = 1.0
	if musicPlayer.stream == menuMusic:
		return
	print("Playing Menu Music")
	musicPlayer.stream = menuMusic
	musicPlayer.play()

func playGameMusic():
	musicPlayer.pitch_scale = 1.0
	#if musicPlayer.stream == gameMusic or musicPlayer.stream == gameMusic2 or musicPlayer.stream == gameMusic3:
	#	return
	var randomTrack = gameMusicTracks.pick_random()
	
	musicPlayer.stream = randomTrack
	musicPlayer.play()

func playCreditsMusic():
	musicPlayer.pitch_scale = 1.0
	if musicPlayer.stream == creditsMusic:
		return
	print("Playing Credits Music")
	musicPlayer.stream = creditsMusic
	musicPlayer.play()

func onGameMusicFinished() -> void:
	if musicPlayer.stream == menuMusic:
		musicPlayer.play()
		print("Playing Menu Music")
	
	var randomTrack = gameMusicTracks.pick_random()
	musicPlayer.stream = randomTrack
	musicPlayer.play()

func lowerPitchMusicPlayer() -> void:
	musicPlayer.pitch_scale = 0.8

func normalPitchMusicPlayer() -> void:
	musicPlayer.pitch_scale = 1.0
