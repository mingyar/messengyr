import React from 'react';
import { connect } from 'react-redux';
import MenuMessage from './menu-message';

class MenuContainer extends React.Component {  
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

MenuContainer.defaultProps = {
	rooms: [],
};

const mapStateToProps = (state) => {
	return {
		rooms: state,
	};
};

MenuContainer = connect(
	mapStateToProps,
)(MenuContainer);

export default MenuContainer;