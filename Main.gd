extends Control

class_name Main

@export var cardBuilderScene : PackedScene
@export var projectPicker : ResourcePicker
@export var basePackPicker : ResourcePicker

var execPath : String

static var dirs : SaveDirs

static var globalClassList : Array[Dictionary]

const TRANSLATIONS : PackedStringArray = [
	"Localisations/LOC - Cards.english.translation",
	"Localisations/LOC - Cards.greek.translation",
	"Localisations/LOC - FlightManual.english.translation",
	"Localisations/LOC - Stat.english.translation",
	"Localisations/LOC - Tutorial.english.translation",
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	execPath = OS.get_executable_path()
	execPath = execPath.replace(execPath.get_file(), "")
	
	if not FileAccess.file_exists(execPath + "SavedDir.tres"):
		ResourceSaver.save(SaveDirs.new(), execPath + "SavedDir.tres")
	
	dirs = ResourceLoader.load(execPath + "SavedDir.tres")
	
	projectPicker.SetFile(dirs.ModDir)
	basePackPicker.SetFile(dirs.BaseDataDir)
	
	ProjectSettings.set_setting("application/config/mod_dir", dirs.ModDir)

func _on_launch_pressed() -> void:
	if (dirs.ModDir.is_empty()):
		print("No dir selected")
		return
	
	if (dirs.BaseDataDir.is_empty()):
		print("No Mod Pack dir selected")
		return
	
	var editor_domain := TranslationServer.get_or_add_domain(&"")
	for locale: String in TRANSLATIONS:
		editor_domain.add_translation(load(dirs.ModDir + "/" +locale))
	editor_domain.set_locale_override("english")
	
	get_child(0).queue_free()
	
	globalClassList = ProjectSettings.get_global_class_list()
	ProjectSettings.load_resource_pack(dirs.BaseDataDir)
	globalClassList.append_array(ProjectSettings.get_global_class_list())
	
	if (FileAccess.file_exists(dirs.ModPackDir)):
		ProjectSettings.load_resource_pack(dirs.ModPackDir)
		globalClassList.append_array(ProjectSettings.get_global_class_list())
	
	CardHelper.LoadModScripts()
	
	var cardB : CardBuilder = cardBuilderScene.instantiate()
	cardB.startingDir = dirs.ModDir
	add_child(cardB)

func _on_base_pack_picker_changed(t: String) -> void:
	dirs.BaseDataDir = t
	ResourceSaver.save(dirs, execPath + "SavedDir.tres")


func _on_project_picker_changed(t: String) -> void:
	dirs.ModDir = t
	ResourceSaver.save(dirs, execPath + "SavedDir.tres")
	print("Captain Directory changed to {0}".format([t]))
	ProjectSettings.set_setting("application/config/mod_dir", dirs.ModDir)
