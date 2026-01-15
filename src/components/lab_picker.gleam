import data/color
import gleam/dynamic/decode
import gleam/float
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_property_change("value", {
        use l <- decode.field("l", decode.float)
        use a <- decode.field("a", decode.float)
        use b <- decode.field("b", decode.float)

        decode.success(ParentChangedValue(color.Lab(l: l, a: a, b: b)))
      }),
    ])

  lustre.register(component, "lab-picker")
}

pub fn element(attributes: List(Attribute(msg))) -> Element(msg) {
  element.element("lab-picker", attributes, [])
}

// Model ----------------------------------------------------------------------

type Model {
  Model(l: String, a: String, b: String)
}

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model("0.0", "0.0", "0.0"), effect.none())
}

// Update ---------------------------------------------------------------------

type Msg {
  ParentChangedValue(color.Lab)
  SetL(String)
  SetA(String)
  SetB(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedValue(color) -> #(
      Model(
        l: float.to_string(color.l),
        a: float.to_string(color.a),
        b: float.to_string(color.b),
      ),
      effect.none(),
    )
    SetL(value) -> #(Model(..model, l: value), effect.none())
    SetA(value) -> #(Model(..model, a: value), effect.none())
    SetB(value) -> #(Model(..model, b: value), effect.none())
  }
}

// View -----------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.styles([
        #("display", "flex"),
      ]),
    ],
    [
      html.label([], [html.text("L*")]),
      html.input([
        attribute.value(model.l),
        event.on_input(SetL),
      ]),
      html.label([], [html.text("a*")]),
      html.input([
        attribute.value(model.a),
        event.on_input(SetA),
      ]),
      html.label([], [html.text("b*")]),
      html.input([
        attribute.value(model.b),
        event.on_input(SetB),
      ]),
    ],
  )
}
