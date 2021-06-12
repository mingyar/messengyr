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
import "phoenix_html";
import ReactDOM from "react-dom";
import "react-phoenix";
import React from "react";
import 'whatwg-fetch';
import { createStore } from 'redux';
import { Provider } from 'react-redux';
import ChatContainer from "./components/chat-container";
import MenuContainer from "./components/menu-container";

const rooms = (state = [], action) => {
	switch (action.type) {
		case "SET_ROOMS":
			return action.rooms;
		
		default:
			return state;
	}
};

const store = createStore(rooms);

class App extends React.Component {
	constructor() {
		super();

		this.state = {
			rooms: [],
			messages: [],
		};
	}

  render() {
    // Pass the relevant data as props:
    return (
      <div id="app">
        <MenuContainer />
        <ChatContainer />
      </div>
    )
  }
}

window.Components = {
  App, 
  MenuContainer, 
  ChatContainer
}

ReactDOM.render(
	<Provider store={store}>
		<App />
	</Provider>,
	document.getElementById('app'),
);
