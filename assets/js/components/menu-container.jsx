import React from 'react';

import MenuMessage from './menu-message';

class MenuContainer extends React.Component {  
  createRoom() {
		let username = prompt("Enter a username");
		console.log(username);
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
          <button 
						className="compose"
						onClick={this.createRoom}
					></button>
        </div>

        <ul>
            {rooms}
        </ul>

      </div>
    )
  }
}

MenuContainer.defaultProps = {
	rooms: [],
};

export default MenuContainer;