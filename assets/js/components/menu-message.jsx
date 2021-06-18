import React from 'react';
import moment from 'moment';
import rooms from '../reducers';

class MenuMessage extends React.Component {
  render() {
    let room = this.props.room;
    let counterpart = room.counterpart;

    // Get the last element of the messages list:
    let lastMessage = room.messages.slice(-1)[0];

		let sentAt;
		let text;

		if (lastMessage) {
    	sentAt = moment.utc(lastMessage.sentAt).fromNow();
			text = lastMessage.text;
		}

		let activeClass = (room.isActive) ? 'active' : '';

    return (
      <li className={activeClass}>
        <img className="avatar" src={counterpart.avatarURL} />
        <div className="profile-container">
          <p className="name">
          {counterpart.username}
          </p>

          <div className="date">
            {sentAt}
          </div>

          <p className="message">
            {text}
          </p>
        </div>

      </li>
    )
  }
}

export default MenuMessage;