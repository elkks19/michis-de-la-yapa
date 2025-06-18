extends Node3D

@onready var jacobita_dmg = $personajes/Jacobita/jacobitaViewport/HUD/dmg
@onready var noah_dmg = $personajes/noah/noahViewport/HUD/dmg
#@onready var audio = $Environment/AudioStreamPlayer

func _ready():
	#audio.play()
	pass

func _on_noah_hit():
	noah_dmg.visible = true
	await get_tree().create_timer(0.2).timeout
	noah_dmg.visible = false

func _on_jacobita_hit():
	jacobita_dmg.visible = true
	await get_tree().create_timer(0.2).timeout
	jacobita_dmg.visible = false
