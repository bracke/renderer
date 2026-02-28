# Draw_Rounded_Rectangle ↔ CSS Quick Reference

| Ada Parameter / Concept               | CSS Equivalent / Notes                                   |
|--------------------------------------|---------------------------------------------------------|
| **Width, Height**                     | `width`, `height` of the element                        |
| **Radius_TL, Radius_TR, Radius_BR, Radius_BL** | `border-top-left-radius`, `border-top-right-radius`, `border-bottom-right-radius`, `border-bottom-left-radius` |
| **Fill_Gradient**                     | `background` (supports `solid`, `linear-gradient`, `radial-gradient`, `conic-gradient`) |
| **Gradient Stops**                    | Color stops in CSS gradients (`0% Red, 100% Blue`)      |
| **Border_Color, Border_Size**         | `border: <width> solid <color>`                        |
| **Shadow_Color**                      | `box-shadow` color including alpha                      |
| **Shadow_Offset_X, Shadow_Offset_Y**  | `box-shadow: <offset-x> <offset-y>`                    |
| **Shadow_Blur**                       | `box-shadow: <blur-radius>`                             |
| **Shadow_Spread**                     | `box-shadow: <spread-radius>`                           |
| **AA_Width**                          | Anti-aliasing; no direct CSS equivalent, smooths edges |
| **Coverage / Alpha_Fill / Alpha_Border** | Opacity / blending; corresponds to alpha channel or `rgba()` in CSS |
| **Rounded_Rect_Distance / SDF**       | Internal technique; corresponds to smooth edges / anti-aliased borders |
| **Render_Context / Buffer**           | Canvas / drawing context; no direct CSS equivalent, internal rendering target |
| **Clip_Rectangle / Clip_Stack**       | `overflow: hidden` or clipping in CSS                  |

---

### Notes

1. **Gradients:** Both Ada and CSS support multiple stops and repeat/reverse options.
2. **Shadows:** Spread, blur, and offset can be combined for CSS-like `box-shadow`.
3. **Borders:** Ada supports independent corner radii; CSS shorthand can set them individually or uniformly.
4. **Anti-Aliasing / Coverage:** Ada uses floating-point coverage for smooth edges, CSS uses subpixel rendering automatically.
5. **Comparison Strategy:** To check visual parity:
   - Render the Ada rectangle into a buffer.
   - Compare against a CSS-rendered div with identical parameters.
   - Minor differences in shadows or edges are acceptable; focus on shape, color, and general appearance.

---

### Example Mapping

| CSS Property Example                                  | Ada Call Equivalent |
|------------------------------------------------------|-------------------|
| `width: 100px; height: 50px;`                       | `Width => 100, Height => 50` |
| `border-radius: 10px 0 5px 0;`                      | `Radius_TL=>10, Radius_TR=>0, Radius_BR=>5, Radius_BL=>0` |
| `background: linear-gradient(to right, red, blue);` | `Fill_Gradient => Linear([Stop(0.0, Red), Stop(1.0, Blue)])` |
| `box-shadow: 0 5px 10px 2px rgba(0,0,0,0.25);`     | `Shadow_Color => (0,0,0,64), Shadow_Offset_X => 0, Shadow_Offset_Y => 5, Shadow_Blur => 10, Shadow_Spread => 2` |