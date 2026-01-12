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
  Model(base0: String, base7: String)
}

fn init(_args) -> Model {
  Model(base0: "#141312", base7: "#dddddd")
}

type Msg {
  SetBase0(String)
  SetBase7(String)
}

fn update(model: Model, msg: Msg) {
  case msg {
    SetBase0(val) -> Model(..model, base0: val)
    SetBase7(val) -> Model(..model, base7: val)
  }
}

fn view(model: Model) -> Element(Msg) {
  let base0 = model.base0
  let base7 = model.base7

  html.div(
    [
      attribute.styles([
        #("width", "100vw"),
        #("height", "100vh"),
        #("display", "flex"),
        #("background-color", base0),
        #("color", base7),
      ]),
    ],
    [
      html.div(
        [
          attribute.styles([
            #("padding", "1rem"),
            #("flex-grow", "1"),
          ]),
        ],
        [],
      ),
      html.form(
        [
          attribute.styles([
            #("padding", "1rem"),
            #("flex-grow", "0"),
            #("display", "flex"),
            #("flex-direction", "column"),
          ]),
        ],
        [
          html.label([], [html.text("Background")]),
          html.input([
            attribute.value(base0),
            event.on_input(SetBase0),
          ]),
          html.label([], [html.text("Text")]),
          html.input([
            attribute.value(base7),
            event.on_input(SetBase7),
          ]),
        ],
      ),
    ],
  )
}
