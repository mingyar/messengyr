import React from 'react';
import ReactDOM from 'react-dom';

import ChatMessage from './chat-message';

class ChatContainer extends React.Component {
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
          <input placeholder="Type a message..." />
          <button>Send</button>
        </div>

      </div>
    )
  }
}

export default ChatContainer;