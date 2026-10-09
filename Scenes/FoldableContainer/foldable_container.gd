extends PanelContainer

class_name FoldableCont

signal MoveUp
signal MoveDown
signal Remove

var title : String :
	set(value):
		title = value
		$VBoxContainer/HBoxContainer/Expand.text = value

var folded : bool :
	set(value):
		folded = value
		FoldToggled(value)



func DissableMoving() -> void:
	$VBoxContainer/HBoxContainer/MoveUp.hide()
	$VBoxContainer/HBoxContainer/MoveDown.hide()

func _ready() -> void:
	child_entered_tree.connect(ChildAdded)

func ChildAdded(newChild : Node) -> void:
	newChild.reparent($VBoxContainer/VBoxContainer)

func GetContainer() -> Control:
	return $VBoxContainer/VBoxContainer

func _on_move_up_pressed() -> void:
	MoveUp.emit()

func _on_move_down_pressed() -> void:
	MoveDown.emit()

func _on_remove_pressed() -> void:
	Remove.emit()

func _on_expand_pressed() -> void:
	folded = !folded

func FoldToggled(t : bool) -> void:
	if (t):
		$VBoxContainer/HBoxContainer/Expand.icon = load("res://Scenes/FoldableContainer/Arrow.png")
	else:
		$VBoxContainer/HBoxContainer/Expand.icon = load("res://Scenes/FoldableContainer/Arrow2.png")
	GetContainer().visible = !t
