extends CardModuleProperty

class_name CardModuleBooleanProperty

@export var box : CheckBox

func SetProperty(pName : String, value : Variant) -> void:
	super(pName, value)
	box.set_pressed_no_signal(value)
