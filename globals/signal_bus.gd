# This was interesting, I was getting some null bullshit until I made sure
# to add the extends Node.
extends Node

# connections:
	# hover_focus:emits
signal hovered(event_data: UiMainClickEvent)
signal main_click(grid_position: Vector2i)

# See also:
	# entity_ctl
	# input_ctl
	# tile_info_ctl
signal current_player_changed(entity: IEntity)

# See also:
	# input_ctl
	# entity_interface
	# move
	# game
	# tile_info_ctl
signal current_player_moved(entity: IEntity)


signal save_game()
