# Limitations / Unsupported Features

While `Draw_Rounded_Rectangle` implements most of the common CSS rectangle features, the following CSS behaviors are **not fully supported**:

| CSS Feature / Behavior                          | Status in `Draw_Rounded_Rectangle`                        | Notes / Workarounds |
|-------------------------------------------------|----------------------------------------------------------|-------------------|
| `border-style` other than `solid`              | ❌ Not supported                                         | Borders are always solid; dashed or dotted are not implemented. |
| `inset box-shadow`                              | ❌ Not supported                                         | Only outer shadows are supported; inset shadows are ignored. |
| Complex CSS gradients with multiple angles / repeating patterns | ⚠ Partially supported                                     | Linear, radial, and conic gradients with stops are supported; some advanced CSS repeat behaviors may differ. |
| CSS border collapse / table-related styles     | ❌ Not applicable                                        | Only standalone rectangles are supported. |
| Rounded corners beyond half of width/height    | ⚠ Clamped                                               | Ada automatically clamps radius to half of width/height to prevent invalid geometry. |
| CSS transforms (`rotate`, `scale`, `skew`)     | ❌ Not supported                                         | Only axis-aligned rectangles are drawn. |
| Fractional pixel positioning (subpixel layout) | ⚠ Limited                                              | Anti-aliasing smooths edges but may differ from browser subpixel rendering. |
| CSS `overflow` / clipping by arbitrary shapes | ❌ Limited                                              | Only a simple rectangular clip is supported. |

**Notes:**
1. Minor visual differences may exist in shadows, gradients, and anti-aliasing due to floating-point calculations versus browser rendering.
2. This table helps set expectations for regression testing and visual comparison with CSS outputs.