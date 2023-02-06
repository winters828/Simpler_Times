extends TileSet
tool

const WOODWALL = 2
const STONEWALL = 4

var binds = {
	WOODWALL : [STONEWALL],
	STONEWALL : [WOODWALL]
}
# Works with the const array above, will bind specific tilesets
func _is_tile_bound(drawn_id, neighbor_id):
	if drawn_id in binds:
		return neighbor_id in binds[drawn_id]
	return false

# func _is_tile_bound(drawn_id, neighbor_id):
#	return neighbor_id in get_tiles_ids()
