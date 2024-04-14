extends Node
class_name LevelController

enum LevelState {
    COUNTDOWN,
    IN_PROGRESS,
    FINISHED
}


@export var goal: Goal = null
@export var player: VehicleController = null
@export var camera: CameraFollow = null
@onready var countdown_label: Label = $CountdownLabel
@onready var timer_label: Label = $TimerLabel
@onready var score_screen: ScorePanelHandler = $ScorePanel
@onready var pause_screen: PausePanelHandler = $PausePanel


#var score_handler: ScoreHandler = ScoreHandler.new()
var level_name: String = ""
var timer: float = 0.0
var state: LevelState = LevelState.COUNTDOWN
var countdown: float = 5.0
var penalties: Array[Penalty] = []
var level_info: LevelInfo = null
var countdown_finished: bool = false



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
    score_screen.set_level_info(level_info)

func start():
    if state == LevelState.COUNTDOWN:
        state = LevelState.IN_PROGRESS
        player.freeze = false
        timer = 0.0

func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
        pause_screen.pause.call_deferred()

    if not countdown_finished:
        update_countdown_label(countdown, true)
        if timer > 2.0:
            countdown_finished = true
        countdown_label.hide()

    if state == LevelState.IN_PROGRESS:
        timer += delta
        update_timer_label()
    elif state == LevelState.COUNTDOWN:
        countdown_label.show()
        countdown -= delta
        if countdown <= 0:
            start()

func update_countdown_label(time: float, with_level: bool = false):
    countdown_label.show()
    countdown_label.text = ""
    if time > 3.0:
        if with_level:
            countdown_label.text = level_info.level_name + "\n"
        countdown_label.text += "Get ready"
    elif time > 0.0:
        if with_level:
            countdown_label.text = level_info.level_name + "\n"
        countdown_label.text += str(int(ceil(time)))
    elif time > -2.0:
        countdown_label.text = "Go!"

func update_timer_label():
    if timer_label:
        timer_label.show()
        timer_label.text = Utils.format_time(timer)


func on_in_goal_area(time_left: float):
    update_countdown_label(time_left)
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
