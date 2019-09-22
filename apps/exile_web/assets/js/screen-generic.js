import css from "../css/screen-generic.scss"
import "phoenix_html"
import {Socket} from "phoenix";

var payload = JSON.parse(decodeURI(document.querySelector('#payload').innerText));
var socket = new Socket("/socket", {});
var channel = socket.channel(`database:${payload.prefix}`, {});

channel.join().receive('ok', response => { console.log('eh');})
socket.connect();

console.log('channel');
