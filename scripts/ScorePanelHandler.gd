extends PanelContainer
class_name ScorePanelHandler

enum ScoreState {
    START,
    SHOW_TIME,
    SHOW_PENALTIES,
    SHOW_TOTAL,
    SHOW_MEDAL,
    READY
}

signal restart_pressed()
signal next_level_pressed()
signal menu_pressed()

const PENALTY_ITEM: PackedScene = preload("res://prefabs/ui/penalty_item.tscn")

@onready var time_label: Label = $VBoxContainer/Panel3/TimeContainer/TimeLabel
@onready var penalty_container: Control = $VBoxContainer/Panel5/PenaltiesContainer/ScrollContainer/PenaltyItemContainer
@onready var penalty_scroll_container: Control = $VBoxContainer/Panel5/PenaltiesContainer/ScrollContainer
@onready var total_label: Label = $VBoxContainer/TotalPanel/TotalContainer/TotalLabel
@onready var menu_button: Button = $VBoxContainer/Panel2/ButtonsContainer/MenuBtn
@onready var restart_button: Button = $VBoxContainer/Panel2/ButtonsContainer/RestartBtn
@onready var next_level_button: Button = $VBoxContainer/Panel2/ButtonsContainer/NextLevelBtn
@onready var level_medal_showcase: MedalShowcaseUI = $VBoxContainer/Panel6/MedalShowcase
@onready var medal_reveal: MedalReveal = $VBoxContainer/TotalPanel2/TotalContainer/MedalReveal

var penalties: Array[Penalty] = []
var state: ScoreState = ScoreState.START
var state_timer: Timer = Timer.new()
var penalty_index: int = 0
var finish_time: float = 0.0
var total_time: float = 0.0
var level_info: LevelInfo = null


# Called when the node enters the scene tree for the first finish_time.
func _ready():
    hide()
    state_timer.timeout.connect(advance_state)
    state_timer.one_shot = true
    add_child(state_timer)
    menu_button.pressed.connect(on_menu_pressed)
    restart_button.pressed.connect(on_restart_pressed)
    next_level_button.pressed.connect(on_next_level_pressed)
    set_buttons_enabled(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
        pass

func advance_state(complete_state: bool = false):
    print("Advacing state, " + str(state))
    match state:
        ScoreState.START:
            time_label.text = ""
            total_label.text = ""
            show()
            state = ScoreState.SHOW_TIME
            next_level_button.grab_focus.call_deferred()
            state_timer.start(1.0)
        ScoreState.SHOW_TIME:
            state = ScoreState.SHOW_PENALTIES
            time_label.text = Utils.format_time(finish_time)
            state_timer.start(1.0)
        ScoreState.SHOW_PENALTIES:
            if penalties.size() == 0:
                var penalty_item = PENALTY_ITEM.instantiate()
                penalty_item.text = "None"
                penalty_container.add_child(penalty_item)
            if penalty_index >= penalties.size():
                state = ScoreState.SHOW_TOTAL
                state_timer.start(0.0)
            else:
                for i in range(penalty_index, penalties.size()):
                    var penalty_item = PENALTY_ITEM.instantiate()
                    penalty_item.text = penalties[penalty_index].reason + "(+" + str(int(penalties[penalty_index].time)) + "s)"
                    penalty_container.add_child(penalty_item)
                    penalty_index += 1
                    await get_tree().process_frame
                    penalty_scroll_container.ensure_control_visible(penalty_item)
                    if not complete_state:
                        state_timer.start(0.5)
                        break
        ScoreState.SHOW_TOTAL:
            state = ScoreState.SHOW_MEDAL
            total_label.text = Utils.format_time(total_time)
            state_timer.start(1.0)
        ScoreState.SHOW_MEDAL:
            state = ScoreState.READY
            medal_reveal.reveal(1.0, Utils.get_medal(total_time, level_info))
            state_timer.start(0.0)
        ScoreState.READY:
            print("Grabbing focus")

func set_buttons_enabled(enabled: bool):
    menu_button.disabled = not enabled
    restart_button.disabled = not enabled
    next_level_button.disabled = not enabled

func show_score(_finish_time: float, _total_time: float, pens: Array[Penalty]):
    get_tree().set_pause.call_deferred(true)
    penalties = pens
    state = ScoreState.START
    state_timer.start(0.0)
    finish_time = _finish_time
    total_time = _total_time
    print("Showing score: ", finish_time, total_time, penalties)

func set_level_info(_level_info: LevelInfo):
    level_info = _level_info
    level_medal_showcase.set_times(level_info)

func on_restart_pressed():
    Utils.restart_scene(get_tree())

func on_menu_pressed():
    Utils.show_menu_scene(get_tree())

func on_next_level_pressed():
    Utils.load_next_or_menu(get_tree(), level_info)
