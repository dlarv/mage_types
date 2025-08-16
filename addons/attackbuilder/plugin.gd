@tool
extends EditorPlugin

var editor

func _enter_tree():
	editor = preload("main.tscn").instantiate()
	# add editor to main viewport
	get_editor_interface().get_editor_main_screen().add_child(editor)
	editor.hide()
	# _make_visible(false)

func _exit_tree():
	# remove from main viewport
	if is_instance_valid(editor):
		editor.queue_free()
	
	print_debug('Plugin Disabled')

func _has_main_screen():
	return true

func _make_visible(visible):
	if is_instance_valid(editor):
		editor.visible = visible

func _get_plugin_name():
	return 'Attack Manager'
