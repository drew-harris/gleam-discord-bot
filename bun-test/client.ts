const socket = new WebSocket("https://gateway.discord.gg");

socket.onopen = () => {
  console.log("Socket opened!");
  socket.send("Hello from the client!");
};

socket.onmessage = (event) => {
  console.log(event.data);
};
