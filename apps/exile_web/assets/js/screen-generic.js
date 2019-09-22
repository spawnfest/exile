import css from "../css/screen-generic.scss"
import "phoenix_html"
import {Socket} from "phoenix";
import {LiveSocket} from 'phoenix_live_view';
import StringifyObject from 'stringify-object';

var liveSocket = new LiveSocket("/live", Socket);
liveSocket.connect();

var payload = JSON.parse(decodeURI(document.querySelector('#payload').innerText));
var socket = new Socket("/socket", {});
var channel = socket.channel(`database:${payload.prefix}`, {token: payload.token});

channel.join();
socket.connect();

window.exile = {
  get: (reference) => {
    return {value: "placeholder"};
  }
};

var consoleHistoryElement = document.querySelector('.console-history');
var consoleFormElement = document.querySelector('.console-form');
var consoleLog = console.log;

var consoleAppend = (message, className) => {
  var item = document.createElement("li");
  item.classList.add(className);
  item.innerText = message;
  consoleHistoryElement.append(item);
};

consoleFormElement.addEventListener("submit", (event) => {
  var command = event.target.elements["command"].value;
  consoleAppend(command, 'request');
  setTimeout(() => {
    try {
      var result = eval('(' + command + ')');
      consoleAppend(StringifyObject(result, {indent: '  '}), 'response');
    } catch (error) {
      consoleAppend(error, 'error');
    }
  });
  event.target.reset();
  event.preventDefault();
}, false);


console.log = function (message) {
  consoleAppend(message, 'log');
  consoleLog.apply(console, arguments);
};

console.log('Hello World');
