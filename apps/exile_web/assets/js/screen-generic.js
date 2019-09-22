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
channel.on("event", event => {
  consoleAppend(StringifyObject(event, {indent: '  '}), 'message');
});

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
  },
  subscribe: function (reference, value) {
    return this.push(channel, "subscribe", {reference: reference});
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

var consoleLogPromise = function (promise) {
  var item = consoleAppend('Promise (Pending…)', 'response');
  promise.then((result) => {
    item.innerText = StringifyObject(result, {indent: '  '});
  }, (reason) => {
    item.innerText = StringifyObject(reason, {indent: '  '});
    item.classList.add('error');
  });
}

consoleFormElement.addEventListener("submit", (event) => {
  var command = event.target.elements["command"].value;
  consoleAppend(command, 'request');
  setTimeout(() => {
    try {
      var result = eval('(' + command + ')');
      if (Promise.resolve(result) == result) {
        consoleLogPromise(result);
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

window.shortcut_subscribe_post = function () {
  consoleHistoryElement.querySelectorAll('*').forEach(function(node) {
    node.remove();
  });

  consoleAppend('Shortcut: Subscribe to `posts`');
  var promise = exile.subscribe('posts');
  consoleAppend("1> exile.subscribe('posts')");
  consoleLogPromise(promise);
}

window.shortcut_get_posts = function () {
  consoleHistoryElement.querySelectorAll('*').forEach(function(node) {
    node.remove();
  });

  consoleAppend('Shortcut: Get Posts');
  var promise = exile.get('posts');
  consoleAppend("1> exile.get('posts')");
  consoleLogPromise(promise);
}

window.shortcut_create_post = function () {
  consoleHistoryElement.querySelectorAll('*').forEach(function(node) {
    node.remove();
  });

  consoleAppend('Shortcut: Create Post');
  var promise = exile.post('posts', {title: 'Hello World', comments: []});
  consoleAppend("1> exile.post('posts', {title: 'Hello World', comments: []})", 'command');
  promise.then((data) => {
    var promise = exile.get(`posts/${data.value}`);
    consoleAppend("2> exile.get(`posts/${data.value}`)", 'command');
    consoleLogPromise(promise);
  });
  consoleLogPromise(promise);
}

window.shortcut_create_post_comment = function () {
  consoleHistoryElement.querySelectorAll('*').forEach(function(node) {
    node.remove();
  });

  consoleAppend('Shortcut: Create Post & Comment');
  var promise = exile.post('posts', {title: 'Hello World', comments: []});
  consoleAppend("1> exile.post('posts', {title: 'Hello World', comments: []})", 'command');
  promise.then((post) => {
    var promise = exile.post(`posts/${post.value}/comments`, {content: 'Hello World!'});
    consoleAppend("2> exile.post(`posts/${post.value}/comments`, {content: 'Hello World!'})", 'command');
    consoleLogPromise(promise);
    promise.then((data) => {
      var promise = exile.get(`posts/${post.value}`);
      consoleAppend("3> exile.get(`posts/${post.value}`)", 'command');
      consoleLogPromise(promise);
    });
  });
  consoleLogPromise(promise);
}

console.log('Hello World');
