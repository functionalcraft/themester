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

type ColorLab {
  ColorLab(l: Float, a: Float, b: Float)
}

type ColorRgb {
  ColorRgb(r: Int, g: Int, b: Int)
}

type ColorState {
  ColorState(
    lab: ColorLab,
    rgb: ColorRgb,
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
  let base0_lab = ColorLab(10.0, 0.0, 0.0)

  let #(base0_rgb, valid_rgb) = case lab_to_rgb(base0_lab) {
    Ok(c) -> #(c, True)
    _ -> #(ColorRgb(10, 10, 10), False)
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
        Ok(v) -> ColorLab(..model.base0.lab, l: v)
        _ -> model.base0.lab
      }
      let #(base0_rgb, valid_rgb) = case lab_to_rgb(base0_lab) {
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
        Ok(v) -> ColorLab(..model.base0.lab, a: v)
        _ -> model.base0.lab
      }
      let #(base0_rgb, valid_rgb) = case lab_to_rgb(base0_lab) {
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
        Ok(v) -> ColorLab(..model.base0.lab, b: v)
        _ -> model.base0.lab
      }
      let #(base0_rgb, valid_rgb) = case lab_to_rgb(base0_lab) {
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
        ],
      ),
    ],
  )
}

fn lab_to_rgb(lab: ColorLab) -> Result(ColorRgb, Nil) {
  // Normalize L*a*b* values
  let fy = { lab.l +. 16.0 } /. 116.0
  let fx = fy +. { lab.a /. 500.0 }
  let fz = fy -. { lab.b /. 200.0 }

  // Inverse L*a*b* nonlinearity
  let xr = inverse_lab_nonlinearity(fx)
  let yr = inverse_lab_nonlinearity(fy)
  let zr = inverse_lab_nonlinearity(fz)

  // Scale by reference white (D65)
  let x = xr *. 0.95047
  let y = yr *. 1.0
  let z = zr *. 1.08883

  let r_lin = 3.2404542 *. x -. 1.5371385 *. y -. 0.4985314 *. z
  let g_lin = -0.969266 *. x +. 1.8760108 *. y +. 0.041556 *. z
  let b_lin = 0.0556434 *. x -. 0.2040259 *. y +. 1.0572252 *. z

  // Linear RGB to sRGB (gamma encoding)
  case srgb_encode(r_lin), srgb_encode(g_lin), srgb_encode(b_lin) {
    Ok(r_), Ok(g_), Ok(b_) ->
      // Scale and fit to [0, 255]
      case scale_and_fit(r_), scale_and_fit(g_), scale_and_fit(b_) {
        Ok(r), Ok(g), Ok(b) -> Ok(ColorRgb(r, g, b))
        _, _, _ -> Error(Nil)
      }
    _, _, _ -> Error(Nil)
  }
}

fn inverse_lab_nonlinearity(t: Float) -> Float {
  let epsilon = 216.0 /. 24_389.0
  let kappa = 24_389.0 /. 27.0

  case t *. t *. t {
    t_cubed if t_cubed >. epsilon -> t_cubed
    _ -> { 116.0 *. t -. 16.0 } /. kappa
  }
}

fn srgb_encode(c: Float) -> Result(Float, Nil) {
  case c {
    c_ if c_ <=. 0.0031308 -> Ok(c_)
    _ ->
      case float.power(c, 1.0 /. 2.4) {
        Ok(c_) -> Ok(1.055 *. c_ -. 0.055)
        _ -> Error(Nil)
      }
  }
}

fn scale_and_fit(x: Float) -> Result(Int, Nil) {
  case float.truncate(x *. 255.0) {
    y if y >= 0 && y <= 255 -> Ok(y)
    _ -> Error(Nil)
  }
}

fn rgb_hex(c: ColorRgb) -> String {
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
