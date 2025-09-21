# This was interesting, I was getting some null bullshit until I made sure
# to add the extends Node.
extends Node

signal hovered(event_data: UiEventData)


signal current_player_changed(entity: Entity)
signal current_player_moved(entity: Entity)