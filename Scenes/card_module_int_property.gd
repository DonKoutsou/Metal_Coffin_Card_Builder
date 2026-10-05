extends CardModuleProperty

class_name CardModuleIntProperty

@export var box : SpinBox

func SetProperty(pName : String, value : Variant) -> void:
	super(pName, value)
	box.set_value_no_signal(value)
