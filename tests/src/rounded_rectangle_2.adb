with AUnit.Assertions;             use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;                     use Renderer;
with Renderer.Rectangle;           use Renderer.Rectangle;
with Renderer.Colors;              use Renderer.Colors;
with Renderer.Gradients;           use Renderer.Gradients;
with Renderer.Gradients.Constants; use Renderer.Gradients.Constants;
with Framebuffer;                  use Framebuffer;
with IO;

package body Rounded_Rectangle_2 is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Rounded rectangle #2");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      C : Render_Context := Create_Context (500, 400);

      Linear_RG : constant Gradient :=
        (Kind          => Linear,
         X1            => 0.0,
         Y1            => 0.0,
         X2            => 100.0,
         Y2            => 0.0,
         Stop_Count    => 2,
         Stops         =>
           [1 => (Position => 0.0, Color => Red),
            2 => (Position => 1.0, Color => Green)],
         Repeat        => True,
         Repeat_Length => 100.0,
         others        => <>);

      Radial_Blue : constant Gradient :=
        (Kind       => Radial,
         CX         => 50.0,
         CY         => 50.0,
         Radius     => 50.0,
         Stop_Count => 2,
         Stops      =>
           [1 => (Position => 0.0, Color => Blue),
            2 => (Position => 1.0, Color => White)],
         others     => <>);

      Conic_Gradient : constant Gradient :=
        (Kind         => Conic,
         CX           => 50.0,
         CY           => 50.0,
         Angle_Offset => 0.0,
         Stop_Count   => 4,
         Stops        =>
           [1 => (Position => 0.0, Color => Red),
            2 => (Position => 0.25, Color => Green),
            3 => (Position => 0.5, Color => Blue),
            4 => (Position => 1.0, Color => Red)],
         others       => <>);

   begin
      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");

      --  Solid rectangle with shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 10, Y => 10, Width => 80, Height => 40),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 1,
              Shadow_Count   => 1,
              Fill           => Solid_Red,
              Border         => Border_Style'(Black, 1),
              Radii          => (0, 0, 0, 0),
              Shadows        =>
                [1 =>
                   (Offset_X => 2,
                    Offset_Y => 2,
                    Blur     => 4,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 80))]));

      --  Linear gradient, no shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 110, Y => 10, Width => 100, Height => 40),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 2,
              Shadow_Count   => 0,
              Fill           => Linear_RG,
              Border         => Border_Style'(Transparent, 1),
              Radii          => (5, 5, 5, 5),
              Shadows        => Empty_Shadow_Array));

      --  Radial gradient with shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 10, Y => 60, Width => 80, Height => 80),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 2,
              Shadow_Count   => 1,
              Fill           => Radial_Blue,
              Border         => Border_Style'(Black, 1),
              Radii          => (20, 20, 20, 20),
              Shadows        =>
                [1 =>
                   (Offset_X => 4,
                    Offset_Y => 4,
                    Blur     => 6,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 100))]));

      --  Conic gradient with shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 110, Y => 60, Width => 100, Height => 100),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 4,
              Shadow_Count   => 1,
              Fill           => Conic_Gradient,
              Border         => Border_Style'(Black, 1),
              Radii          => (10, 30, 50, 0),
              Shadows        =>
                [1 =>
                   (Offset_X => 0,
                    Offset_Y => 4,
                    Blur     => 8,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 50))]));

      --  Zero-width/height rectangles, no shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 10, Y => 160, Width => 0, Height => 50),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 1,
              Shadow_Count   => 0,
              Fill           => Solid_Red,
              Border         => Border_Style'(Black, 1),
              Shadows        => Empty_Shadow_Array,
             others => <>
            )
         );
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 10, Y => 160, Width => 50, Height => 0),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 1,
              Shadow_Count   => 0,
              Fill           => Solid_Red,
              Border         => Border_Style'(Black, 1),
              Shadows        => Empty_Shadow_Array,
              others => <>)
              );

      --  Max radius rectangle (circle) with shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 200, Y => 180, Width => 60, Height => 60),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 1,
              Shadow_Count   => 1,
              Fill           => Solid_Red,
              Border         => Border_Style'(Black, 1),
              Radii          => (30, 30, 30, 30),
              Shadows        =>
                [1 =>
                   (Offset_X => 3,
                    Offset_Y => 3,
                    Blur     => 10,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 120))]));

      --  Overlapping rectangles
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 300, Y => 10, Width => 120, Height => 80),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 2,
              Shadow_Count   => 1,
              Fill           => Linear_RG,
              Border         => Border_Style'(Black, 1),
              Radii          => (10, 10, 10, 10),
              Shadows        =>
                [1 =>
                   (Offset_X => 6,
                    Offset_Y => 6,
                    Blur     => 8,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 60))]));

      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 340, Y => 40, Width => 120, Height => 80),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 2,
              Shadow_Count   => 1,
              Fill           => Radial_Blue,
              Border         => Border_Style'(Black, 1),
              Radii          => (10, 10, 10, 10),
              Shadows        =>
                [1 =>
                   (Offset_X => 0,
                    Offset_Y => 0,
                    Blur     => 6,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 60))]));

      --  Semi-transparent shadow
      declare
         Semi_Transparent_Red : constant Pixel :=
           (R => 255, G => 0, B => 0, A => 128);
      begin
         Draw_Rounded_Rectangle
           (C,
            Geometry => (X => 10, Y => 250, Width => 100, Height => 50),
            Style    =>
              Rectangle_Style'
                (Gradient_Count => 1,
                 Shadow_Count   => 1,
                 Fill           => Solid_Red,
                 Border         => Border_Style'(Black, 1),
                 Radii          => (10, 10, 10, 10),
                 Shadows        =>
                   [1 =>
                      (Offset_X => 4,
                       Offset_Y => 4,
                       Blur     => 6,
                       Spread   => 0,
                       Inset    => False,
                       Color    => Semi_Transparent_Red)]));
      end;

      --  Repeating radial gradient with shadow
      declare
         Repeating_Radial : constant Gradient :=
           (Kind          => Radial,
            CX            => 50.0,
            CY            => 50.0,
            Radius        => 40.0,
            Stop_Count    => 2,
            Stops         =>
              [1 => (Position => 0.0, Color => Red),
               2 => (Position => 1.0, Color => Green)],
            Repeat        => True,
            Repeat_Length => 40.0,
            others        => <>);
      begin
         Draw_Rounded_Rectangle
           (C,
            Geometry => (X => 150, Y => 250, Width => 100, Height => 100),
            Style    =>
              Rectangle_Style'
                (Gradient_Count => 2,
                 Shadow_Count   => 1,
                 Fill           => Repeating_Radial,
                 Border         => Border_Style'(Black, 1),
                 Radii          => (10, 10, 10, 10),
                 Shadows        =>
                   [1 =>
                      (Offset_X => 5,
                       Offset_Y => 5,
                       Blur     => 10,
                       Spread   => 0,
                       Inset    => False,
                       Color    => (0, 0, 0, 80))]));
      end;

      --  Extreme clipping rectangle with shadow
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => -50, Y => -50, Width => 100, Height => 100),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 1,
              Shadow_Count   => 1,
              Fill           => Solid_Red,
              Border         => Border_Style'(Black, 1),
              Radii          => (10, 10, 10, 10),
              Shadows        =>
                [1 =>
                   (Offset_X => 4,
                    Offset_Y => 4,
                    Blur     => 6,
                    Spread   => 0,
                    Inset    => False,
                    Color    => (0, 0, 0, 100))]));

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/rounded_rectangle_2.ppm");

   end Run_Test;

end Rounded_Rectangle_2;
