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
  push: function (channel, message, params) {
    return new Promise((resolve, reject) => {
      channel.push(message, params)
        .receive("ok", data => resolve(data))
        .receive("error", reason => reject(reason))
        .receive("timeout", (() => reject("timeout")));
    });
  },
  get: function (reference) {
    return this.push(channel, "get", {reference: reference});
  },
  post: function (reference, value) {
    return this.push(channel, "post", {reference: reference, value: value});
  },
  put: function (reference, value) {
    return this.push(channel, "post", {reference: reference, value: value});
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
  return item;
};

consoleFormElement.addEventListener("submit", (event) => {
  var command = event.target.elements["command"].value;
  consoleAppend(command, 'request');
  setTimeout(() => {
    try {
      var result = eval('(' + command + ')');
      if (Promise.resolve(result) == result) {
        var item = consoleAppend('Promise (Pending…)', 'response');
        result.then((result) => {
          item.innerText = StringifyObject(result, {indent: '  '});
        }, (reason) => {
          item.innerText = StringifyObject(reason, {indent: '  '});
          item.classList.add('error');
        });
      } else {
        consoleAppend(StringifyObject(result, {indent: '  '}), 'response');
      }
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

var defaultCallback = (result) => {
  consoleAppend("Received: ", 'log');
  consoleAppend(StringifyObject(result, {indent: '  '}), 'log');
}

console.log('Hello World');
