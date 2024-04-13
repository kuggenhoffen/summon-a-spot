extends Node

@export var goal: Goal = null
@export var player: VehicleController = null
@export var camera: CameraFollow = null

# Called when the node enters the scene tree for the first time.
func _ready():
    goal.connect("player_finished", on_player_finished)
    camera.target = player
    

func on_player_finished():
    print("Player finished the level!")
