// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

let user_id = uuidv4()
console.log(user_id)

let socket = new Socket("/socket", {params: {user_id} })
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("project:1", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

let editButton = document.getElementById('edit-button')
socket.onMessage(({ topic, event, payload }) => {
  if (event == "editing_enabled"
        && topic == `project:1:editor:${user_id}`) {
    editButton.classList.toggle("disabled");
  }
})

editButton.onclick = function() {
  alert('Project successfully edited!')
}

export default socket
