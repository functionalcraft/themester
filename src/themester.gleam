import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(
    base0: String,
    base7: String,
  )
}

fn init(_args) -> Model {
  Model(
    base0: "#141312",
    base7: "#dddddd",
  )
}

type Msg {
}

fn update(model: Model, _msg: Msg) {
  model
  // case msg {
  //   Increment -> model + 1
  //   Decrement -> model - 1
  // }
}

fn view(model: Model) -> Element(Msg) {
  let base0 = model.base0
  let base7 = model.base7

  html.div(
    [
      attribute.styles([
        #("width", "100vw"),
        #("height", "100vw"),
        #("background-color", base0),
        #("color", base7),
      ])
    ], 
    [
      html.p([], [html.text(base0)]),
    ]
  )
}
