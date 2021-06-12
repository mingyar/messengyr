export function setRooms(rooms) {
  return {
    type: "SET_ROOMS",
    rooms,
  }
};

export function selectRoom(roomId) {
	return {
		type: "SELECT_ROOM",
		roomId,
	}
};