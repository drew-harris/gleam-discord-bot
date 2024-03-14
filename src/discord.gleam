import gleam/httpc
import gleam/http.{Get, Post, Put}
import gleam/erlang/process
import gleam/option.{None}
import stratus
import gleam/dynamic.{type Dynamic}
import gleam/io
import gleam/result
import gleam/http/request
import gleam/json.{array, int, null, object, string}
import gleam/otp/actor

pub type Msg {
  Close
  SendText(String)
}

fn get_ws_url() -> Result(String, Dynamic) {
  let assert Ok(req) = request.to("https://discord.com/api/gateway")
  use resp <- result.try(httpc.send(req))
  io.debug(resp.body)
  Ok("done")
}

fn create_msg_body(msg: String) {
  object([#("content", string(msg))])
  |> json.to_string
}

fn build_base_discord_req() {
  request.new()
  |> request.set_host("discord.com")
  |> request.set_header("Authorization", "Bot " <> "BOT_TOKEN_HERE")
  |> request.set_header("Content-Type", "application/json")
}

fn send_message(msg: String) {
  let body = create_msg_body(msg)

  let updated =
    build_base_discord_req()
    |> request.set_path("api/channels/1120455140416172115/messages")
    |> request.set_method(Post)
    |> request.set_body(body)

  use result <- result.try(httpc.send(updated))

  io.debug(3)
  io.debug(result.status)
  io.debug(result.body)
  Ok("done")
}

pub fn do_websocket() {
  let assert Ok(req) = request.to("https://gateway.discord.gg")
  let req =
    req
    |> request.set_header("connection", "Upgrade")
    |> request.set_header("upgrade", "websocket")
  let builder =
    stratus.websocket(
      request: req,
      init: fn() { #(Nil, None) },
      loop: fn(msg, state, conn) {
        case msg {
          stratus.Text(_msg) -> {
            let assert Ok(_resp) =
              stratus.send_text_message(conn, "hello, world!")
            actor.continue(state)
          }
          stratus.User(SendText(msg)) -> {
            let assert Ok(_resp) = stratus.send_text_message(conn, msg)
            actor.continue(state)
          }
          stratus.Binary(_msg) -> actor.continue(state)
          stratus.User(Close) -> {
            let assert Ok(_) = stratus.close(conn)
            actor.Stop(process.Normal)
          }
        }
      },
    )
    |> stratus.on_close(fn(_state) { io.println("oh noooo") })

  stratus.initialize(builder)
}

pub fn main() {
  //   let res =
  //     send_message(
  //       "hi",
  //     )
  //   io.debug(res)
  let res = do_websocket()
  io.debug(res)
}
