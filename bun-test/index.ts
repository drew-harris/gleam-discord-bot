Bun.serve({
  port: 3000,
  fetch(req, server) {
    if (server.upgrade(req)) {
      return; // do not return a Response
    }
    return new Response("Upgrade failed :(", { status: 500 });
  }, // upgrade logic
  websocket: {
    message(ws, message) {
      console.log(message); // log the message
    }, // a message is received
    open(ws) {
      console.log("Socket opened!"); // log the event
      ws.sendText("Hello from Bun!"); // send a message to the client
    }, // a socket is opened
    close(ws, code, message) {}, // a socket is closed
    drain(ws) {}, // the socket is ready to receive more data
  },
});

