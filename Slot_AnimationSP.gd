extends Control
class_name SlotAnimationSP

@export var interact_button:Button
var index:int = 0

var container:Node
func _ready() -> void:
	pivot_offset = size / 2
	interact_button.button_down.connect(press_down)
	interact_button.mouse_entered.connect(mouse_enter)
	container = get_parent() as HBoxContainerAnimationSP
	container.drag_slot.connect(check_drag.bind(true))
	container.put_slot.connect(check_drag.bind(false))
	long_press_timer = Timer.new()
	long_press_timer.one_shot = true
	long_press_timer.wait_time = 0.25
	add_child(long_press_timer)
	long_press_timer.timeout.connect(drag)
	
var dragging_self:bool = false
var dragging_others:bool = false
func check_drag(type:bool):
	if type and not dragging_self:
		dragging_others = true
	else:
		dragging_others = false
	
func press_down() -> void:
	long_press(true)

func drag():
	container.slot_drag(self,index)
	dragging_self = true
	drag_state.emit(true)
	tweem_killer()
	z_index = 100
	global_position = get_global_mouse_position() - pivot_offset
	
var long_press_timer:Timer
func long_press(type:bool):
	if type:
		long_press_timer.start()
	else:
		long_press_timer.stop()
		
func mouse_enter():
	if dragging_others:
		container.move_ph(index)
		
func tweem_killer():
	if position_anime != null:
		position_anime.kill()
		
var position_anime:Tween
func sort_animation(target,tween_trans,tween_ease,tween_duration):
	if position == target:
		return
	tweem_killer()
	position_anime = create_tween()
	position_anime.set_trans(tween_trans)
	position_anime.set_ease(tween_ease)
	position_anime.tween_property(self,"position",target,tween_duration)

signal drag_state(type:bool)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and dragging_self:
		global_position = event.global_position - pivot_offset
	if event is InputEventMouseButton and not event.pressed:
		if dragging_self:
			container.slot_put()
			dragging_self = false
			interact_button.mouse_filter = MOUSE_FILTER_STOP
			drag_state.emit(false)
		long_press(false)
		z_index = 0
		
func _notification(what):
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size / 2
