extends Node

enum LOCATIONS { START, GAME, SHOP }

signal location_changed(location: LOCATIONS)
signal apples_changed(apples: int)
signal knives_changed()
