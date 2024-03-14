const socket = new WebSocket("ws://localhost:3000");

socket.onopen = () => {
  console.log("Socket opened!");
  socket.send("Hello from the client!");
};

socket.onmessage = (event) => {
  console.log(event.data);
};
