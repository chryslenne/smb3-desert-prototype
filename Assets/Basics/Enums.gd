enum Directions
{
	None,
	N,
	W,
	S,
	E
}
static func DirectionToVector2(dir):
	match dir:
		Directions.N:
			return Vector2.UP
		Directions.S:
			return Vector2.DOWN
		Directions.E:
			return Vector2.RIGHT
		Directions.W:
			return Vector2.LEFT
	return Vector2.ZERO
