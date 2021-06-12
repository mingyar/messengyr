import React from 'react';
import { connect } from 'react-redux';
import MenuMessage from './menu-message';

class MenuContainer extends React.Component {  
	
	componentDidMount() {
		fetch('/api/rooms', {
			headers: {
				"Authorization": "Bearer " + window.jwtToken,
			},
		})
		.then((response) => {
			return response.json();
		})
		.then((response) => {
			let rooms = response.rooms;

			this.props.setRooms(rooms);
		})
		.catch((err) => {
			console.error(err);
		});
	}


  render() {

    let rooms = this.props.rooms.map((room) => {
      return (
        <MenuMessage
          key={room.id}
          room={room}
        />
      );
    });

    return (
      <div className="menu">

        <div className="header">
          <h3>Messages</h3>
          <button className="compose"></button>
        </div>

        <ul>
            {rooms}
        </ul>

      </div>
    )
  }
}

let setRooms = (rooms) => {
	return {
		type: "SET_ROOMS",
		rooms,
	}
};

MenuContainer.defaultProps = {
	rooms: [],
};

const mapStateToProps = (state) => {
	return {
		rooms: state,
	};
};

const mapDispatchToProps = {
	setRooms,
};

MenuContainer = connect(
	mapStateToProps,
	mapDispatchToProps,
)(MenuContainer);

export default MenuContainer;