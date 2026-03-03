with AUnit.Assertions;     use AUnit.Assertions;
with Renderer;             use Renderer;
with Renderer.Rectangle;   use Renderer.Rectangle;
with Renderer.Gradients;   use Renderer.Gradients;

with Renderer.Colors;      use Renderer.Colors;
with Framebuffer;          use Framebuffer;
with IO;
package body Debug is

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Debug");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      Context : Render_Context (600, 600);

      Geometry : constant Rectangle_Geometry := (X => 50, Y => 50, Width => 200, Height => 100);

      Style : constant Rectangle_Style := (
            Shadow_Count => 1,
            Gradient_Count => 1,
            Fill => (
               Stop_Count => 1,
               Kind => Solid,
               Stops => [1 => (Position => 0.0, Color => Renderer.Colors.Blue)],
               others => <>
            ),
            Border => (Size => 0, Color => Black),
            Radii => (TL => 20, TR => 20, BR => 20, BL => 20),
            Shadows =>
            [1 => (Offset_X => 10, Offset_Y => 10, Blur => 20, Spread => 0, Color => Gray, Inset => True)]
         );

      procedure Clear_Rect
        (Context : in out Render_Context;
         X, Y    : Integer;
         Width   : Natural;
         Height  : Natural;
         Color   : Pixel)
      is
         G     : constant Gradient := Solid (Color);
         Geo   : constant Rectangle_Geometry := (X => X, Y => Y, Width => Width, Height => Height);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 0,
            Gradient_Count => 1,
            Fill           => G,
            Border         => No_Border,
            Radii          => (0, 0, 0, 0),
            Shadows        => Empty_Shadow_Array);
      begin
         Draw_Rounded_Rectangle (Context, Geo, Style);
      end Clear_Rect;
   begin
      Clear_Rect (Context, 0, 0, 600, 600, (255, 255, 255, 255));

      Draw_Rounded_Rectangle (Context, Geometry, Style);
      IO.Write_PPM (Get_Buffer (Context), "output/debug.ppm");
   end Run_Test;

end Debug;