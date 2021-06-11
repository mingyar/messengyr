// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"
import "../css/header.scss";
import "../css/messages.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import "react-phoenix"
import React from "react"
import 'whatwg-fetch'

import ChatContainer from "./components/chat-container";
import MenuContainer from "./components/menu-container";

class App extends React.Component {
	constructor() {
		super();

		this.state = {
			rooms: [],
			messages: [],
		};
	}

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
			let rooms = response.rooms

			console.log(rooms)
			this.setState({
			 	rooms: rooms,
			 	messages: rooms[0].messages,
		 	});
		})
		.catch((err) => {
			console.error(err);
		});
	}

  render() {
    // Pass the relevant data as props:
    return (
      <div id="app">
        <MenuContainer 
          rooms={this.state.rooms} 
        />
        <ChatContainer 
          messages={this.state.messages}
        />
      </div>
    )
  }
}

window.Components = {
  App, 
  MenuContainer, 
  ChatContainer
}
