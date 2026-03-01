# TODO

- Does DrawLine need to be as complicated or is there debug cruft?
- Other draw primitives / shapes?
- Buttons?
- Show framebuffer in window?
- Tests / compare pictures (very small ones) using predefined Byte arrays in tests?





1. Buttons

    Regular buttons (submit, button, reset)

    Outline buttons (just set a transparent fill and colored border)

    Can emulate Bootstrap-style buttons, Material-style buttons, or custom colored buttons.

2. Input Fields

    Text inputs (<input type="text">)

    Password inputs (<input type="password">)

    Number inputs (<input type="number">)

    Date/time inputs (<input type="date">)

    With rounded corners, border, and background gradient.

    Limitation: No cursor or text is drawn; you’d need a separate text rendering routine.

3. Textareas

    Large rectangular areas for multi-line text.

    Can use gradients and shadows for “elevated” effect.

    Rounded corners can mimic modern form design.

4. Checkbox / Radio backgrounds

    You can draw the background or box of checkboxes/radios.

    Rounded corners make circular radio buttons easy.

    The check mark itself would need a separate shape-drawing routine.

5. Select boxes / Dropdowns

    The dropdown container can be drawn with Draw_Rounded_Rectangle.

    Highlighting or expanded dropdown content can be drawn as additional rectangles with shadow and gradient.

6. Sliders / Track bars

    The track (background rectangle) can be drawn.

    The thumb can also be a small rounded rectangle or circle.

    Color gradients allow for progress indication.

7. Panels / Cards

    Non-interactive containers like Bootstrap cards.

    Rounded corners, gradients, shadows, and borders make them visually consistent.

⚠️ Not handled directly

    Text content – you’d need a font rendering routine.

    Icons – separate vector or bitmap drawing.

    Interactive states (hover, focus, pressed) – must be implemented manually.

    Complex forms like sliders with ticks, scrollbars, or select dropdowns with options.

In short: your routine is a general-purpose rectangular shape renderer, suitable for almost all visual blocks in a form, but not the content inside them. With text rendering and small shape primitives (lines, circles), you could create entire GUI forms.

If you want, I can make a diagram showing exactly which HTML form elements you could “mock” with just this rectangle routine. It would be a nice visual mapping.



- minimal automated regression test harness
- Or a performance benchmark harness
- Add CSS-accurate border rendering

    Adjust this to pass gnatpp cleanly with a specific switch set

    Format to match SPARK profile style

    If you like, I can also produce a side-by-side CSS-parity test harness that generates reference images for regression testing using this exact procedure. That would make verifying visual parity much easier.

 If you want next-level realism, we can improve blur to be Gaussian-like instead of linear falloff — but that would increase complexity.


 If you'd like next-level refinement, we can address the blur center alignment relative to Kernel_Bounds — but that’s optional.
 If you want, I can also update the Sample_Gradient and Interpolate_Color functions to avoid repeated declare blocks for further minor speedup. This would make the entire package fully optimized.

 If you want, I can also apply smoothstep to the border separately, so that borders have soft edges independently of fill, like modern CSS.

 If you'd like next, we can:

Merge Rounded_Rect_Distance to accept Corner_Radii directly

Or refactor shadows to accept Rectangle_Geometry + Rectangle_Style

Or make this fully object-oriented using tagged types