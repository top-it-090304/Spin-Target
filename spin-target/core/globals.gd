extends Node

var location_to_scene := {
	Events.LOCATIONS.GAME: preload("res://scens/game/game.tscn"),
	Events.LOCATIONS.START: preload("res://scens/start_screen/start_screen.tscn"),
	Events.LOCATIONS.SHOP: preload("res://scens/knife_shop/knife_shop.tscn")

}

var rmg := RandomNumberGenerator.new()
func _ready():
	rmg.randomize()
	
	Events.location_changed.connect(handle_location_change)
	
func handle_location_change(location: Events.LOCATIONS):
	get_tree().change_scene_to_packed(location_to_scene.get(location))
	
