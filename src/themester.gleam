import components/lab_picker
import data/color.{type Lab, type Rgb}
import gleam/float
import gleam/int
import gleam/string
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

type ColorState {
  ColorState(
    lab: color.Lab,
    rgb: color.Rgb,
    l: String,
    a: String,
    b: String,
    valid_rgb: Bool,
  )
}

type Model {
  Model(base0: ColorState, base7: String)
}

fn init(_args) -> Model {
  let base0_lab = color.Lab(10.0, 0.0, 0.0)

  let #(base0_rgb, valid_rgb) = case color.lab_to_rgb(base0_lab) {
    Ok(c) -> #(c, True)
    _ -> #(color.Rgb(10, 10, 10), False)
  }

  let base0 =
    ColorState(
      lab: base0_lab,
      rgb: base0_rgb,
      valid_rgb: valid_rgb,
      l: float.to_string(base0_lab.l),
      a: float.to_string(base0_lab.a),
      b: float.to_string(base0_lab.b),
    )

  Model(base0: base0, base7: "#dddddd")
}

type Msg {
  SetBase0L(String)
  SetBase0A(String)
  SetBase0B(String)
  SetBase7(String)
}

fn update(model: Model, msg: Msg) {
  case msg {
    SetBase0L(val) -> {
      let base0_lab = case parse_float_permissive(val) {
        Ok(v) -> color.Lab(..model.base0.lab, l: v)
        _ -> model.base0.lab
      }
      let #(base0_rgb, valid_rgb) = case color.lab_to_rgb(base0_lab) {
        Ok(c) -> #(c, True)
        _ -> #(model.base0.rgb, False)
      }
      Model(
        ..model,
        base0: ColorState(
          ..model.base0,
          lab: base0_lab,
          rgb: base0_rgb,
          valid_rgb: valid_rgb,
          l: val,
        ),
      )
    }

    SetBase0A(val) -> {
      let base0_lab = case parse_float_permissive(val) {
        Ok(v) -> color.Lab(..model.base0.lab, a: v)
        _ -> model.base0.lab
      }
      let #(base0_rgb, valid_rgb) = case color.lab_to_rgb(base0_lab) {
        Ok(c) -> #(c, True)
        _ -> #(model.base0.rgb, False)
      }
      Model(
        ..model,
        base0: ColorState(
          ..model.base0,
          lab: base0_lab,
          rgb: base0_rgb,
          valid_rgb: valid_rgb,
          a: val,
        ),
      )
    }

    SetBase0B(val) -> {
      let base0_lab = case parse_float_permissive(val) {
        Ok(v) -> color.Lab(..model.base0.lab, b: v)
        _ -> model.base0.lab
      }
      let #(base0_rgb, valid_rgb) = case color.lab_to_rgb(base0_lab) {
        Ok(c) -> #(c, True)
        _ -> #(model.base0.rgb, False)
      }
      Model(
        ..model,
        base0: ColorState(
          ..model.base0,
          lab: base0_lab,
          rgb: base0_rgb,
          valid_rgb: valid_rgb,
          b: val,
        ),
      )
    }

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
        #("background-color", rgb_hex(base0.rgb)),
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
          html.label([], [
            html.text("Background ("),
            html.text(rgb_hex(base0.rgb)),
            html.text(case base0.valid_rgb {
              True -> ")"
              False -> "*)"
            }),
          ]),
          html.div(
            [
              attribute.styles([
                #("display", "flex"),
              ]),
            ],
            [
              html.label([], [html.text("L*")]),
              html.input([
                attribute.value(base0.l),
                event.on_input(SetBase0L),
              ]),
              html.label([], [html.text("a*")]),
              html.input([
                attribute.value(base0.a),
                event.on_input(SetBase0A),
              ]),
              html.label([], [html.text("b*")]),
              html.input([
                attribute.value(base0.b),
                event.on_input(SetBase0B),
              ]),
            ],
          ),
          html.label([], [html.text("Text")]),
          html.input([
            attribute.value(base7),
            event.on_input(SetBase7),
          ]),
          html.label([], [html.text("Foo")]),
          lab_picker.element([]),
        ],
      ),
    ],
  )
}

fn rgb_hex(c: color.Rgb) -> String {
  string.concat([
    "#",
    hex_byte(c.r),
    hex_byte(c.g),
    hex_byte(c.b),
  ])
}

fn hex_byte(x: Int) -> String {
  let s = int.to_base16(x)
  case string.length(s) {
    0 -> "00"
    1 -> string.concat(["0", s])
    2 -> s
    _ -> "FF"
  }
}

fn parse_float_permissive(s: String) -> Result(Float, Nil) {
  case float.parse(s), int.parse(s) {
    Ok(v), _ -> Ok(v)
    _, Ok(v) -> Ok(int.to_float(v))
    _, _ -> Error(Nil)
  }
}
