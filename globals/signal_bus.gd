# This was interesting, I was getting some null bullshit until I made sure
# to add the extends Node.
extends Node

signal hovered(event_data: UiEventData)
signal left_clicked(grid_position: Vector2i)

signal current_player_changed(entity: IEntity)
signal current_player_moved(entity: IEntity)
