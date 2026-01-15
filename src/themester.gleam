import components/lab_picker
import data/color
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/io
import gleam/json
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)

  let assert Ok(_) = lab_picker.register()

  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type ColorState {
  ColorState(lab: color.Lab, rgb: color.Rgb, valid_rgb: Bool)
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

  let base0 = ColorState(lab: base0_lab, rgb: base0_rgb, valid_rgb: valid_rgb)

  Model(base0: base0, base7: "#dddddd")
}

type Msg {
  SetBase0Lab(color.Lab)
  SetBase7(String)
}

fn update(model: Model, msg: Msg) {
  case msg {
    SetBase0Lab(base0_lab) -> {
      io.println(
        "Parent: Received SetBase0Lab with L="
        <> float.to_string(base0_lab.l)
        <> " a="
        <> float.to_string(base0_lab.a)
        <> " b="
        <> float.to_string(base0_lab.b),
      )
      let #(base0_rgb, valid_rgb) = case color.lab_to_rgb(base0_lab) {
        Ok(c) -> {
          io.println(
            "Parent: Lab to RGB conversion succeeded: #"
            <> int.to_base16(c.r)
            <> int.to_base16(c.g)
            <> int.to_base16(c.b),
          )
          #(c, True)
        }
        _ -> {
          io.println("Parent: Lab to RGB conversion failed")
          #(model.base0.rgb, False)
        }
      }
      Model(
        ..model,
        base0: ColorState(lab: base0_lab, rgb: base0_rgb, valid_rgb: valid_rgb),
      )
    }

    SetBase7(val) -> {
      io.println("Parent: Setting base7 to " <> val)
      Model(..model, base7: val)
    }
  }
}

fn view(model: Model) -> Element(Msg) {
  let base0 = model.base0
  let base7 = model.base7

  io.println(
    "Parent view: Rendering with base0.lab L="
    <> float.to_string(base0.lab.l)
    <> " a="
    <> float.to_string(base0.lab.a)
    <> " b="
    <> float.to_string(base0.lab.b),
  )

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
          lab_picker.element([
            attribute.property(
              "value",
              json.object([
                #("l", json.float(base0.lab.l)),
                #("a", json.float(base0.lab.a)),
                #("b", json.float(base0.lab.b)),
              ]),
            ),
            event.on("change", {
              use c <- decode.field("detail", {
                use l <- decode.field("l", decode.float)
                use a <- decode.field("a", decode.float)
                use b <- decode.field("b", decode.float)
                decode.success(color.Lab(l: l, a: a, b: b))
              })
              decode.success(SetBase0Lab(c))
            }),
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
