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
  Model(
    base0: ColorState,
    base1: ColorState,
    base2: ColorState,
    base3: ColorState,
    base4: ColorState,
    base5: ColorState,
    base6: ColorState,
    base7: ColorState,
  )
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let base0 = color_state(color.Lab(10.0, 4.0, 1.0))
  let base1 = color_state(color.Lab(20.0, 4.5, 1.3))
  let base2 = color_state(color.Lab(30.0, 5.0, 1.6))
  let base3 = color_state(color.Lab(40.0, 5.5, 1.9))
  let base4 = color_state(color.Lab(60.0, 6.0, 2.2))
  let base5 = color_state(color.Lab(70.0, 6.5, 2.5))
  let base6 = color_state(color.Lab(80.0, 7.0, 2.8))
  let base7 = color_state(color.Lab(90.0, 7.5, 3.1))

  let model = Model(
    base0: base0,
    base1: base1,
    base2: base2,
    base3: base3,
    base4: base4,
    base5: base5,
    base6: base6,
    base7: base7,
  )

  let eff =
    effect.from(fn(_) {
      let _ = set_root_style_property("--base0", rgb_hex(base0.rgb))
      let _ = set_root_style_property("--base1", rgb_hex(base1.rgb))
      let _ = set_root_style_property("--base2", rgb_hex(base2.rgb))
      let _ = set_root_style_property("--base3", rgb_hex(base3.rgb))
      let _ = set_root_style_property("--base4", rgb_hex(base4.rgb))
      let _ = set_root_style_property("--base5", rgb_hex(base5.rgb))
      let _ = set_root_style_property("--base6", rgb_hex(base6.rgb))
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
  SetBase2Lab(color.Lab)
  SetBase3Lab(color.Lab)
  SetBase4Lab(color.Lab)
  SetBase5Lab(color.Lab)
  SetBase6Lab(color.Lab)
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
      let new_model = Model(..model, base1: new_state)

      #(new_model, eff)
    }

    SetBase2Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base2, "--base2")
      let new_model = Model(..model, base2: new_state)

      #(new_model, eff)
    }

    SetBase3Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base3, "--base3")
      let new_model = Model(..model, base3: new_state)

      #(new_model, eff)
    }

    SetBase4Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base4, "--base4")
      let new_model = Model(..model, base4: new_state)

      #(new_model, eff)
    }

    SetBase4Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base4, "--base4")
      let new_model = Model(..model, base4: new_state)

      #(new_model, eff)
    }

    SetBase5Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base5, "--base5")
      let new_model = Model(..model, base5: new_state)

      #(new_model, eff)
    }

    SetBase6Lab(lab) -> {
      let #(new_state, eff) = update_color(lab, model.base6, "--base6")
      let new_model = Model(..model, base6: new_state)

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
      view_example(),
      view_settings(model),
    ],
  )
}

fn view_example() {
  html.div(
    [
      attribute.styles([
        #("padding", "1rem"),
        #("flex-grow", "1"),
      ]),
    ],
    [
      html.div(
        [attribute.class("surface")],
        [
          html.h1([], [html.text("Welcome to Themester")]),
          html.p([], [html.text("Sample text")]),
          html.div(
            [attribute.class("elevated")],
            [
              html.p([], [html.text("Sample elevated text")]),
            ]
          ),
        ],
      ),
    ],
  )
}

fn view_settings(model: Model) -> Element(Msg) {
  html.div(
    [attribute.styles([#("padding", "1rem")])],
    [
  html.div(
    [attribute.class("surface")],
    [
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

          view_lab_picker_label("Base 2", model.base2),
          view_lab_picker(model.base2, SetBase2Lab),

          view_lab_picker_label("Base 3", model.base3),
          view_lab_picker(model.base3, SetBase3Lab),
          
          view_lab_picker_label("Base 4", model.base4),
          view_lab_picker(model.base4, SetBase4Lab),
          
          view_lab_picker_label("Base 5", model.base5),
          view_lab_picker(model.base5, SetBase5Lab),
          
          view_lab_picker_label("Base 6", model.base6),
          view_lab_picker(model.base6, SetBase6Lab),
          
          view_lab_picker_label("Base 7", model.base7),
          view_lab_picker(model.base7, SetBase7Lab),

          html.p([], [
            html.text("Background: Base 0"),
            html.br([]),
            html.text("Surface: Base 1"),
            html.br([]),
            html.text("Elevated: Base 2"),
            html.br([]),
            html.text("Text: Base 7"),
          ]),
        ],
      ),
    ]
  )
  ])
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
