extends Container
class_name HBoxContainerAnimationSP
##Slot必须继承SlotAnimationSP
##你受够了BoxContainer的自动排布了吗？想要添加动画却无从下手？立刻使用BoxContainerAnimationSupport！！！
@export_group("Arguments")
@export var separation:float = 10.0
##非常重要且优化不了的问题，需要指定一个容器用于存放拖拽的节点，因为拖拽节点时会将节点移出当前容器，请勿指定其他会自动排列布局的容器，否则可能会出现问题
@export var drag_container:Node
@export_group("Animation")
@export var tween_trans:Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC
@export var tween_ease:Tween.EaseType = Tween.EaseType.EASE_OUT
@export var tween_duration:float = 0.5

##子节点容器，用于绕过queue_free()导致get_children()返回结果非预期
var children_array:Array = []
func _ready() -> void:
	if drag_container == null:
		push_error("drag_container is null")
	sort_children.connect(sort_position)

##排列容器里的元素，已经连接上了Container的sort_children信号
func sort_position():
	var space:float = 0.0
	children_array = get_children()
	var max_height:float = 0.0
	for index in children_array.size():
		var slot = children_array[index]
		slot.index = index
		slot.sort_animation(Vector2(space,0),tween_trans,tween_ease,tween_duration)
		space += slot.size.x + separation
		if slot.size.y > max_height:
			max_height = slot.size.y
	custom_minimum_size = Vector2(space - separation, max_height)
	
##长按并拖拽Slot时发出
signal drag_slot
##松开Slot时发出
signal put_slot
##有效地移动了Slot时发出
signal move_slot(from:int,to:int)
##拖拽节点引用缓存
var drag_cache:Node
##用于检测是否有效地移动了Slot
var old_index:int = 0

func slot_drag(slot:Node,target_index:int):
	old_index = target_index
	create_ph(slot,target_index)
	drag_cache = slot
	slot.reparent(drag_container)
	slot.interact_button.mouse_filter = MOUSE_FILTER_IGNORE
	drag_slot.emit()
	
func slot_put():
	var target_index:int = hp.get_index()
	move_slot.emit(old_index,target_index)
	hp.reparent(drag_container)
	drag_cache.reparent(self)
	move_child(drag_cache,target_index)
	put_slot.emit()
	hp.queue_free()
	
##占位节点引用缓存
var hp:Node
func create_ph(slot:Node,target_index:int):
	hp = slot.duplicate(DUPLICATE_SCRIPTS)
	hp.modulate.a = 0.3
	add_child(hp)
	move_ph(target_index)

func move_ph(target_index:int):
	move_child(hp,target_index)
