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

import DATA from './fake-data';

class App extends React.Component {
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
			console.log(response);
		})
		.catch((err) => {
			console.error(err);
		});
	}

  render() {
    // Extract the data:
    const ROOMS = DATA.rooms;
    const MESSAGES = DATA.rooms[0].messages;

    // Pass the relevant data as props:
    return (
      <div id="app">
        <MenuContainer 
          rooms={ROOMS} 
        />
        <ChatContainer 
          messages={MESSAGES}
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
