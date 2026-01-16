import gleam/float

pub type Lab {
  Lab(l: Float, a: Float, b: Float)
}

pub type Rgb {
  Rgb(r: Int, g: Int, b: Int)
}

pub fn lab_to_rgb_permissive(lab: Lab) -> Result(#(Rgb, Bool), Nil) {
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
        #(r, True), #(g, True), #(b, True) -> Ok(#(Rgb(r, g, b), True))
        #(r, _), #(g, _), #(b, _) -> Ok(#(Rgb(r, g, b), True))
      }
    _, _, _ -> Error(Nil)
  }
}

pub fn lab_to_rgb(lab: Lab) -> Result(Rgb, Nil) {
  case lab_to_rgb_permissive(lab) {
    Ok(#(c, True)) -> Ok(c)
    _ -> Error(Nil)
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

fn scale_and_fit(x: Float) -> #(Int, Bool) {
  case float.truncate(x *. 255.0) {
    y if y >= 0 && y <= 255 -> #(y, True)
    y if y > 255 -> #(255, False)
    _ -> #(0, False)
  }
}
