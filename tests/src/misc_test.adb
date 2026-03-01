with AUnit.Assertions;             use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;                     use Renderer;
with Renderer.Rectangle;           use Renderer.Rectangle;
with Renderer.Gradients;           use Renderer.Gradients;
with Renderer.Gradients.Constants; use Renderer.Gradients.Constants;
with Renderer.Colors;              use Renderer.Colors;
with Framebuffer;                  use Framebuffer;
with IO;
with Ada.Numerics;

package body Misc_Test is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Miscellaneous");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      C  : Render_Context := Create_Context (600, 400);
      C2 : Render_Context := Create_Context (600, 400);

      Solid_Gradient : constant Gradient :=
        Solid ((R => 40, G => 44, B => 52, A => 255));

      Linear_Gradient : constant Gradient :=
        (Kind          => Linear,
         X1            => 120.0,
         Y1            => 10.0,
         X2            => 170.0,
         Y2            => 10.0,
         Stop_Count    => 2,
         Stops         =>
           [1 => (Position => 0.0, Color => (255, 0, 0, 255)),
            2 => (Position => 1.0, Color => (255, 255, 255, 255))],
         Repeat        => True,
         Repeat_Length => 20.0,
         others        => <>);

      Radial_Gradient : constant Gradient :=
        (Kind          => Radial,
         CX            => 245.0,
         CY            => 60.0,
         Radius        => 25.0,
         Stop_Count    => 2,
         Stops         =>
           [1 => (0.0, (0, 0, 255, 255)), 2 => (1.0, (255, 255, 255, 255))],
         Repeat        => True,
         Repeat_Length => 30.0,
         others        => <>);

      Conic_Gradient : constant Gradient :=
        (Kind          => Conic,
         CX            => 35.0,
         CY            => 200.0,
         Angle_Offset  => 0.0,
         Stop_Count    => 6,
         Stops         =>
           [1 => (0.0, (255, 0, 0, 255)),
            2 => (0.2, (255, 255, 0, 255)),
            3 => (0.4, (0, 255, 0, 255)),
            4 => (0.6, (0, 255, 255, 255)),
            5 => (0.8, (0, 0, 255, 255)),
            6 => (1.0, (255, 0, 0, 255))],
         Repeat        => True,
         Repeat_Length => Ada.Numerics.Pi / 2.0,
         others        => <>);

   begin
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      IO.Write_PPM (Get_Buffer (C), "output/blank.ppm");

      --  Rounded rectangles using new style
      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 10, Y => 10, Width => 50, Height => 100);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 0,
            Gradient_Count => 1,
            Fill           => Solid_Gradient,
            Border         => (Color => Green, Size => 10),
            Radii          => (20, 20, 20, 20),
            others         => <>);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      declare
         Geo   : constant Rectangle_Geometry := (120, 10, 50, 100);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 0,
            Gradient_Count => 2,
            Fill           => Linear_Gradient,
            Border         => (Color => Green, Size => 10),
            Radii          => (20, 20, 20, 20),
            others         => <>);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      declare
         Geo   : constant Rectangle_Geometry := (220, 10, 50, 100);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 0,
            Gradient_Count => 2,
            Fill           => Radial_Gradient,
            Border         => (Color => Green, Size => 10),
            Radii          => (20, 20, 20, 20),
            others         => <>);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      --  Rectangle with shadow
      declare
         Geo   : constant Rectangle_Geometry := (10, 150, 50, 250);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 1,
            Gradient_Count => 6,
            Fill           => Conic_Gradient,
            Border         => (Color => Green, Size => 10),
            Radii          => (20, 20, 20, 20),
            Shadows        =>
              [1 =>
                 (Offset_X => 0,
                  Offset_Y => 6,
                  Blur     => 20,
                  Spread   => 0,
                  Inset    => False,
                  Color    => (0, 0, 0, 120))]);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/filled_rounded_rectangle_2.ppm");

      --  Another rectangle with shadow on second context
      declare
         Geo   : constant Rectangle_Geometry := (50, 50, 200, 100);
         Style : constant Rectangle_Style :=
           (Fill           => Solid_White,
            Shadow_Count   => 1,
            Gradient_Count => 1,
            Border         => (Color => (0, 0, 0, 255), Size => 4),
            Radii          => (20, 20, 20, 20),
            Shadows        =>
              [1 =>
                 (Offset_X => 10,
                  Offset_Y => 10,
                  Blur     => 15,
                  Spread   => 0,
                  Inset    => False,
                  Color    => (0, 0, 0, 180))]);
      begin
         Draw_Rounded_Rectangle (C2, Geo, Style);
      end;

      IO.Write_PPM (Get_Buffer (C2), "output/rectangle_width_shadow.ppm");

   end Run_Test;

end Misc_Test;
