extends Node

enum LOCATIONS { START, GAME, SHOP, SETTINGS }

signal location_changed(location: LOCATIONS)
signal apples_changed(apples: int)
signal knives_changed()
signal combo_changed(combo: int, multiplier: float)
signal combo_broken()
