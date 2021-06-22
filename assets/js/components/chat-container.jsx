import React from 'react';
import ChatMessage from './chat-message';
import { connect } from 'react-redux';

function scrollToBotton() {
	let chatEL = document.querySelector('.chat ul');

	if (!chatEL) return false;

	chatEL.scrollTop = chatEL.scrollHeight;
}

class ChatContainer extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			draft: '',
		};
	}

	updateDraft(e) {
		this.setState({
			draft: e.target.value,
		});
	}

	sendMessage() {
		let message = this.state.draft;

		if (!message) return false;

		let room = this.props.room;

		room.channel.push('message:new', {
			text: message,
			room_id: room.id,
	});

		this.setState({
			draft: ''
		});
	}

	handleKeyPress(e) {
		if (e.key === "Enter") {
			this.sendMessage();
		}
	}

  render() {
    
    let messages = this.props.messages.map((message) => {
      return (
        <ChatMessage
          key={message.id}
          message={message}
        />
      );
    });
    
    return (
      <div className="chat">

        <ul>
          {messages}
        </ul>

        <div className="compose-box">
          <input 
						placeholder="Type a message..."
						value={this.state.draft}
						onChange={this.updateDraft.bind(this)}
						onKeyPress={this.handleKeyPress.bind(this)}
					/>
          <button onClick={this.sendMessage.bind(this)}>
						Send
					</button>
        </div>

      </div>
    )
  }

	/*
   * Check if a new room is selected or if a message is added.
   * If it is, scroll down!
   */
	componentDidUpdate(prevProps) {
		let prevRoomId = prevProps.room && prevProps.room.id;
		let newRoomId = this.props.room && this.props.room.id;

		let prevNumMessages = prevProps.messages.length;
		let newNumMessages = this.props.messages.length;

		let changedRoom = (prevRoomId !== newRoomId);
		let addedMessage = (prevNumMessages !== newNumMessages);

		if (changedRoom || addedMessage){
			scrollToBotton();
		}
	}
}

ChatContainer.defaultProps = {
	messages: [],
};

const mapStateToProps = (state) => {
  // Get only the active room:
  let activeRoom = state.filter((room) => {
    return room.isActive;
  })[0];

  return {
    // If there is an active room, get its messages!
    // Otherwise, just return an empty list
    messages: (activeRoom) ? activeRoom.messages : [],
		room: activeRoom,
  }
};

ChatContainer = connect(
  mapStateToProps,
)(ChatContainer);

export default ChatContainer;