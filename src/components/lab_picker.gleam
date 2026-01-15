import data/color
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/io
import gleam/json
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
    ParentChangedValue(color) -> {
      io.println(
        "Component: Parent changed value to L="
        <> float.to_string(color.l)
        <> " a="
        <> float.to_string(color.a)
        <> " b="
        <> float.to_string(color.b),
      )
      #(
        Model(
          l: float.to_string(color.l),
          a: float.to_string(color.a),
          b: float.to_string(color.b),
        ),
        effect.none(),
      )
    }
    SetL(value) -> {
      io.println("Component: SetL to " <> value)
      let new_model = Model(..model, l: value)
      #(new_model, emit_if_valid(new_model))
    }
    SetA(value) -> {
      io.println("Component: SetA to " <> value)
      let new_model = Model(..model, a: value)
      #(new_model, emit_if_valid(new_model))
    }
    SetB(value) -> {
      io.println("Component: SetB to " <> value)
      let new_model = Model(..model, b: value)
      #(new_model, emit_if_valid(new_model))
    }
  }
}

fn parse_float_permissive(s: String) -> Result(Float, Nil) {
  case float.parse(s), int.parse(s) {
    Ok(v), _ -> Ok(v)
    _, Ok(v) -> Ok(int.to_float(v))
    _, _ -> Error(Nil)
  }
}

fn emit_if_valid(model: Model) -> Effect(Msg) {
  case
    parse_float_permissive(model.l),
    parse_float_permissive(model.a),
    parse_float_permissive(model.b)
  {
    Ok(l), Ok(a), Ok(b) -> {
      io.println(
        "Component: Emitting change event with L="
        <> float.to_string(l)
        <> " a="
        <> float.to_string(a)
        <> " b="
        <> float.to_string(b),
      )
      let lab_json =
        json.object([
          #("l", json.float(l)),
          #("a", json.float(a)),
          #("b", json.float(b)),
        ])
      effect.event("change", lab_json)
    }
    _, _, _ -> {
      io.println(
        "Component: Invalid values, not emitting: l="
        <> model.l
        <> " a="
        <> model.a
        <> " b="
        <> model.b,
      )
      effect.none()
    }
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
