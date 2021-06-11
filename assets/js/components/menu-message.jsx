import React from 'react';
import moment from 'moment';

class MenuMessage extends React.Component {
  render() {
    let room = this.props.room;
    let counterpart = room.counterpart;

    // Get the last element of the messages list:
    let lastMessage = room.messages.slice(-1)[0];
    let sentAt = moment.utc(lastMessage.sentAt).fromNow();

    return ( 
      <li>
        <img className="avatar" src={counterpart.avatarURL} />

        <div className="profile-container">
          <p className="name">
          {counterpart.username}
          </p>

          <date>
            {sentAt}
          </date>

          <p className="message">
            {lastMessage.text}
          </p>
        </div>

      </li>
    )
  }
}

export default MenuMessage;