extends Node
class_name LevelController

enum LevelState {
    COUNTDOWN,
    IN_PROGRESS,
    FINISHED
}


const BEEP_SHORT: AudioStream = preload("res://sfx/beep_short.wav")
const BEEP_LONG: AudioStream = preload("res://sfx/beep_long.wav")


@export var goal: Goal = null
@export var player: VehicleController = null
@export var camera: CameraFollow = null
@onready var countdown_label: Label = $CountdownLabel
@onready var timer_label: Label = $TimerLabel
@onready var score_screen: ScorePanelHandler = $ScorePanel
@onready var pause_screen: PausePanelHandler = $PausePanel
@onready var audio_player: AudioStreamPlayer = $AudioPlayer


#var score_handler: ScoreHandler = ScoreHandler.new()
var level_name: String = ""
var timer: float = 0.0
var state: LevelState = LevelState.COUNTDOWN
var countdown: float = 5.0
var penalties: Array[Penalty] = []
var level_info: LevelInfo = null
var countdown_finished: bool = false
var current_countdown: int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
    player = get_node("Vehicle")
    goal = get_node("Goal")
    camera = get_node("Camera3D")
    level_info = get_parent().get_meta("level_info")
    goal.player_left_goal_area.connect(on_left_goal_area)
    goal.player_in_goal_area.connect(on_in_goal_area)
    camera.target = player
    player.freeze = true
    player.tire_popped.connect(add_penalty.bind(Penalty.new(2.0, "Popped tire")))
    player.collateral_damage.connect(add_penalty)
    player.fell_off.connect(restart_level)
    countdown_label.show()
    timer_label.hide()
    pause_screen.hide()
    pause_screen.set_level_info(level_info)
    score_screen.set_level_info(level_info)
    score_screen.play_sound.connect(play_sfx)


func start():
    if state == LevelState.COUNTDOWN:
        state = LevelState.IN_PROGRESS
        player.freeze = false
        timer = 0.0
        play_sfx(BEEP_LONG)

func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
        pause_screen.pause.call_deferred()

    if not countdown_finished:
        update_countdown_label(ceil(countdown), true)
        if timer > 2.0:
            countdown_finished = true
            countdown_label.hide()

    if state == LevelState.IN_PROGRESS:
        timer += delta
        update_timer_label()
    elif state == LevelState.COUNTDOWN:
        countdown -= delta
        if countdown <= 0:
            start()
        else:
            var new_countdown = ceil(countdown)
            if new_countdown > 0 and new_countdown <= 3 and new_countdown != current_countdown:
                current_countdown = ceil(countdown)
                play_sfx(BEEP_SHORT)

func update_countdown_label(time: int, with_level: bool = false):
    countdown_label.show()
    countdown_label.text = ""
    if time > 3.0:
        if with_level:
            countdown_label.text = level_info.level_name + "\n"
        countdown_label.text += "Get ready"
    elif time > 0.0:
        if with_level:
            countdown_label.text = level_info.level_name + "\n"
        countdown_label.text += str(time)
    elif time > -2.0:
        countdown_label.text = "Go!"

func update_timer_label():
    if timer_label:
        timer_label.show()
        timer_label.text = Utils.format_time(timer)


func on_in_goal_area(time_left: float):
    update_countdown_label(ceil(time_left))
    if time_left <= 0:
        countdown_label.hide()
        on_player_finished()

func on_left_goal_area():
    if state == LevelState.IN_PROGRESS:
        countdown_label.hide()

func on_player_finished():
    if state == LevelState.IN_PROGRESS:
        print("Player finished the level in ", timer, " seconds!")
        state = LevelState.FINISHED
        var level_time = timer
        var total_time = level_time
        for penalty in penalties:
            total_time += penalty.time
        score_screen.show_score(level_time, total_time, penalties)
        ScoreHandler.update_score(level_info, total_time)

func add_penalty(penalty: Penalty):
    if penalty == null:
        return
    penalties.append(penalty)
    print("Penalty added: ", penalty.reason, " (", penalty.time, " seconds)")

func restart_level():
    get_tree().reload_current_scene.call_deferred()

func on_menu_pressed():
    Utils.show_menu_scene(get_tree())

func on_resume_pressed():
    unpause()

func on_next_level_pressed():
    pass

func toggle_pause_menu():
    if pause_screen.visible:
        unpause()
    else:
        pause()

func pause():
    pause_screen.show()
    get_tree().paused = true
    
func unpause():
    pause_screen.hide()
    get_tree().paused = false


func play_sfx(sfx: AudioStream):
    audio_player.stream = sfx
    audio_player.play()

