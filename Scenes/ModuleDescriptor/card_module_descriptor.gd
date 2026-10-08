extends FoldableContainer

class_name CardModuleDescriptor

@export var modulePropertiesParent : Control

signal MoveUp
signal MoveDown
signal Remove

func GetModulePropertyParent() -> Control:
	return modulePropertiesParent


func DissableMoving() -> void:
	$VBoxContainer/HBoxContainer/MoveUp.hide()
	$VBoxContainer/HBoxContainer/MoveDown.hide()

func _on_move_up_pressed() -> void:
	MoveUp.emit()


func _on_move_down_pressed() -> void:
	MoveDown.emit()


func _on_remove_pressed() -> void:
	var confirm = ConfirmationDialog.new()
	get_tree().root.add_child(confirm)
	confirm.popup_centered()
	confirm.title = ""
	confirm.dialog_text = "Remove Module ?"
	confirm.ok_button_text = "Yes"
	confirm.cancel_button_text = "No"
	confirm.confirmed.connect(RemoveConfirmed)

func RemoveConfirmed() -> void:
	queue_free()
	Remove.emit()
