import components/lab_picker
import data/color
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

@external(javascript, "./themester_ffi.mjs", "set_root_style_property")
fn set_root_style_property(property: String, value: String) -> Nil

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)

  let assert Ok(_) = lab_picker.register()

  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MODEL ----------------------------------------------------------------------

type ColorState {
  ColorState(lab: color.Lab, rgb: color.Rgb, valid_rgb: Bool)
}

type Model {
  Model(base0: ColorState, base1: ColorState, base7: ColorState)
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let base0 = color_state(color.Lab(10.0, 0.0, 0.0))
  let base1 = color_state(color.Lab(20.0, 0.0, 0.0))
  let base7 = color_state(color.Lab(90.0, 0.0, 0.0))

  let model = Model(base0: base0, base1: base1, base7: base7)

  let eff =
    effect.from(fn(_) {
      let _ = set_root_style_property("--base0", rgb_hex(base0.rgb))
      let _ = set_root_style_property("--base1", rgb_hex(base1.rgb))
      set_root_style_property("--base7", rgb_hex(base7.rgb))
    })

  #(model, eff)
}

fn color_state(lab: color.Lab) -> ColorState {
  let #(rgb, valid) = case color.lab_to_rgb_permissive(lab) {
    Ok(x) -> x
    Error(_) -> #(color.Rgb(128, 128, 128), False)
  }

  ColorState(lab: lab, rgb: rgb, valid_rgb: valid)
}

// UPDATE ---------------------------------------------------------------------

type Msg {
  SetBase0Lab(color.Lab)
  SetBase1Lab(color.Lab)
  SetBase7Lab(color.Lab)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    SetBase0Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base0, "--base0")
      let new_model = Model(..model, base0: new_state)

      #(new_model, eff)
    }

    SetBase1Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base1, "--base1")
      let new_model = Model(..model, base0: new_state)

      #(new_model, eff)
    }

    SetBase7Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base7, "--base7")
      let new_model = Model(..model, base7: new_state)

      #(new_model, eff)
    }
  }
}

fn update_color(
  lab: color.Lab,
  prior: ColorState,
  css_var: String,
) -> #(ColorState, Effect(Msg)) {
  let #(rgb, valid_rgb) = case color.lab_to_rgb(lab) {
    Ok(c) -> #(c, True)
    _ -> #(prior.rgb, False)
  }
  let new_state = ColorState(lab: lab, rgb: rgb, valid_rgb: valid_rgb)

  let eff =
    effect.from(fn(_) { set_root_style_property(css_var, rgb_hex(rgb)) })

  #(new_state, eff)
}

// VIEW -----------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.styles([
        #("width", "100vw"),
        #("height", "100vh"),
        #("display", "flex"),
        #("background-color", "var(--background)"),
        #("color", "var(--content)"),
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
        [
          html.div(
            [
              attribute.styles([
                #("padding", "1rem"),
                #("background-color", "var(--surface)"),
                #("color", "var(--content)"),
              ]),
            ],
            [
              html.h1([], [html.text("Sample Header")]),
              html.p([], [html.text("Sample text")]),
            ],
          ),
        ],
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
          view_lab_picker_label("Base 0", model.base0),
          view_lab_picker(model.base0, SetBase0Lab),

          view_lab_picker_label("Base 1", model.base1),
          view_lab_picker(model.base1, SetBase1Lab),

          view_lab_picker_label("Base 7", model.base7),
          view_lab_picker(model.base7, SetBase7Lab),
        ],
      ),
    ],
  )
}

fn view_lab_picker_label(name: String, col: ColorState) -> Element(Msg) {
  html.label([], [
    html.text(name),
    html.text(" ("),
    html.text(rgb_hex(col.rgb)),
    html.text(case col.valid_rgb {
      True -> ")"
      False -> "*)"
    }),
  ])
}

fn view_lab_picker(col: ColorState, msg: fn(color.Lab) -> Msg) -> Element(Msg) {
  lab_picker.element([
    attribute.property(
      "value",
      json.object([
        #("l", json.float(col.lab.l)),
        #("a", json.float(col.lab.a)),
        #("b", json.float(col.lab.b)),
      ]),
    ),
    event.on("change", {
      use c <- decode.field("detail", {
        use l <- decode.field("l", decode.float)
        use a <- decode.field("a", decode.float)
        use b <- decode.field("b", decode.float)
        decode.success(color.Lab(l: l, a: a, b: b))
      })
      decode.success(msg(c))
    }),
  ])
}

// HELPERS --------------------------------------------------------------------

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
