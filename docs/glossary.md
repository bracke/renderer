# Glossary

This glossary explains the terms and concepts used in `Draw_Rounded_Rectangle`, comparing them to CSS concepts where relevant.

---

## **General Terms**

- **Rectangle**
  The basic shape drawn by the procedure. Width and Height determine the size.

- **Corner Radius (Radius_TL, Radius_TR, Radius_BR, Radius_BL)**
  Specifies the rounding of each corner in pixels.
  - `Radius_TL` – Top-left corner radius
  - `Radius_TR` – Top-right corner radius
  - `Radius_BR` – Bottom-right corner radius
  - `Radius_BL` – Bottom-left corner radius
  Equivalent to CSS `border-radius`, supporting individual corner values.

- **Border / Border_Color / Border_Size**
  The outer edge of the rectangle.
  - `Border_Color` specifies the color of the border.
  - `Border_Size` specifies thickness in pixels.
  Equivalent to CSS `border: <width> <style> <color>` (style is always solid).

---

## **Fill / Gradient Terms**

- **Fill_Gradient**
  Determines the interior fill of the rectangle. Can be:
  - **Solid** – a single color (`#RRGGBB` or Pixel).
  - **Linear Gradient** – color transition along a line.
  - **Radial Gradient** – color radiates from a central point outward.
  - **Conic Gradient** – colors arranged around a central point based on angle.
  Equivalent to CSS `background` with `linear-gradient`, `radial-gradient`, or `conic-gradient`.

- **Gradient Stop**
  A color and position pair within a gradient. Determines how colors transition.
  Example: `(0.0, Red)` – color at start; `(1.0, Blue)` – color at end.

- **Gamma Correction**
  Converts between sRGB and linear color space for smooth gradients. Ensures interpolated colors appear visually correct.

---

## **Shadow Terms**

- **Shadow_Color**
  Color of the shadow cast by the rectangle. Includes alpha (opacity).

- **Shadow_Offset_X / Shadow_Offset_Y**
  Horizontal and vertical distance of the shadow from the rectangle. Positive values move right/down, negative values move left/up.
  Equivalent to CSS `box-shadow: <offset-x> <offset-y>`.

- **Shadow_Blur**
  Amount of blur applied to the shadow edges. Higher values produce softer shadows.
  Equivalent to CSS `box-shadow: <blur-radius>`.

- **Shadow_Spread**
  Expands or contracts the shadow beyond the rectangle’s bounds.
  Positive values make shadow larger; negative shrink it.
  Equivalent to CSS `box-shadow: <spread-radius>`.

---

## **Anti-Aliasing & Coverage**

- **AA_Width**
  The width used for anti-aliasing the rectangle edges. Smooths edges to reduce pixelation.

- **Coverage / Alpha_Fill / Alpha_Border**
  Fractional pixel coverage used for blending the fill and border. Ranges from 0.0 (transparent) to 1.0 (opaque).

---

## **Blending / Pixel Terms**

- **Pixel (R, G, B, A)**
  Represents a single pixel’s red, green, blue, and alpha (opacity) values.

- **Blend_Pixel**
  Combines source color with the destination pixel using alpha blending. Implements standard “over” compositing.

- **Clamp**
  Ensures a value stays within a specific range. For example, keeping RGB channels between 0–255 or coverage between 0–1.

---

## **Distance & SDF Terms**

- **Rounded_Rect_Distance**
  Signed distance from a pixel to the nearest point on the rectangle with rounded corners. Used to compute anti-aliasing coverage and shadows.

- **SDF (Signed Distance Field)**
  Technique where each pixel stores distance to the shape’s edge. Useful for smooth edges, shadows, and borders.

---

## **Gaussian Kernel / Blur Terms**

- **Gaussian Kernel**
  Array of weights used to apply a blur via convolution. Determines how the shadow spreads smoothly.

- **Horizontal / Vertical Blur**
  Separates 2D blur into two 1D passes for efficiency.

---

## **Additional Terms**

- **Clip_Rectangle / Clip_Stack**
  The area of the buffer where drawing is allowed. Ensures shapes do not overwrite pixels outside the clipping region.

- **Render_Context**
  Holds the pixel buffer and clipping stack. Passed to `Draw_Rounded_Rectangle` for rendering.

- **Buffer / Pixel_Array**
  The 2D array representing the canvas where pixels are drawn.

- **Spread vs Blur in CSS vs Ada**
  - `Spread` changes the shadow size before blur.
  - `Blur` softens the shadow edges.
  Both combined produce CSS-like shadows.

---

### References

- CSS `border-radius`: https://developer.mozilla.org/en-US/docs/Web/CSS/border-radius
- CSS `background-gradient`: https://developer.mozilla.org/en-US/docs/Web/CSS/gradient
- CSS `box-shadow`: https://developer.mozilla.org/en-US/docs/Web/CSS/box-shadow