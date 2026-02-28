with AUnit.Assertions;              use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;                      use Renderer;
with Renderer.Rectangle;            use Renderer.Rectangle;
with Renderer.Gradients;            use Renderer.Gradients;
with Renderer.Colors;               use Renderer.Colors;
with Framebuffer;                   use Framebuffer;
with Renderer.Gradients.Constants;  use Renderer.Gradients.Constants;
with IO;

package body Rounded_Rectangle_2 is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Rounded rectangle #1");
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

      --------------------------------
      --  1. Solid rectangle
      --------------------------------
      Draw_Rounded_Rectangle
        (C,
         10, 10, 80, 40,
         0, 0, 0, 0,
         Solid_Red,
         Black,
         2,
         Shadows => (1 => (Offset_X => 2,
                           Offset_Y => 2,
                           Blur     => 4,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,80))) );

      ------------------------------------------------
      --  2. Linear gradient horizontal, no border
      ------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         110, 10, 100, 40,
         5, 5, 5, 5,
         Linear_RG,
         Transparent,
         0,
         Shadows => Empty_Shadow_Array);

      -----------------------------------
      --  3. Radial gradient with border
      -----------------------------------
      Draw_Rounded_Rectangle
        (C,
         10, 60, 80, 80,
         20, 20, 20, 20,
         Radial_Blue,
         Black,
         3,
         Shadows => (1 => (Offset_X => 4,
                           Offset_Y => 4,
                           Blur     => 6,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,100))) );

      --------------------------------------
      --  4. Conic gradient with repeating
      --------------------------------------
      Draw_Rounded_Rectangle
        (C,
         110, 60, 100, 100,
         10, 30, 50, 0,
         Conic_Gradient,
         Black,
         2,
         Shadows => (1 => (Offset_X => 0,
                           Offset_Y => 4,
                           Blur     => 8,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,50))) );

      -------------------------------------
      --  5. Zero-width/height rectangles
      -------------------------------------
      Draw_Rounded_Rectangle(C, 10, 160, 0, 50, 0, 0, 0, 0, Solid_Red, Black, 2,
                             Shadows => Empty_Shadow_Array);
      Draw_Rounded_Rectangle(C, 10, 160, 50, 0, 0, 0, 0, 0, Solid_Red, Black, 2,
                             Shadows => Empty_Shadow_Array);

      ---------------------------------------
      --  6. Max radius rectangle (circle)
      ---------------------------------------
      Draw_Rounded_Rectangle
        (C,
         200, 180, 60, 60,
         30, 30, 30, 30,
         Solid_Red,
         Black,
         2,
         Shadows => (1 => (Offset_X => 3,
                           Offset_Y => 3,
                           Blur     => 10,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,120))) );

      --------------------------------
      --  7. Overlapping rectangles
      --------------------------------
      Draw_Rounded_Rectangle
        (C,
         300, 10, 120, 80,
         10, 10, 10, 10,
         Linear_RG,
         Black,
         2,
         Shadows => (1 => (Offset_X => 6,
                           Offset_Y => 6,
                           Blur     => 8,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,60))) );

      Draw_Rounded_Rectangle
        (C,
         340, 40, 120, 80,
         10, 10, 10, 10,
         Radial_Blue,
         Black,
         2,
         Shadows => (1 => (Offset_X => 0,
                           Offset_Y => 0,
                           Blur     => 6,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,60))) );

      --------------------------------------------------
      --  8. Partial alpha rectangle (50% transparent)
      --------------------------------------------------
      declare
         Semi_Transparent_Red : constant Pixel := (R => 255, G => 0, B => 0, A => 128);
      begin
         Draw_Rounded_Rectangle
           (C,
            10, 250, 100, 50,
            10, 10, 10, 10,
            Solid_Red,
            Black,
            2,
            Shadows => (1 => (Offset_X => 4,
                              Offset_Y => 4,
                              Blur     => 6,
                              Spread   => 0,
                              Inset    => False,
                              Color    => Semi_Transparent_Red)) );
      end;

      --------------------------------
      --  9. Repeating radial gradient
      --------------------------------
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
            150, 250, 100, 100,
            10, 10, 10, 10,
            Repeating_Radial,
            Black,
            2,
            Shadows => (1 => (Offset_X => 5,
                              Offset_Y => 5,
                              Blur     => 10,
                              Spread   => 0,
                              Inset    => False,
                              Color    => (0,0,0,80))) );
      end;

      -----------------------------------------
      --  10. Extreme clipping (outside buffer)
      -----------------------------------------
      Draw_Rounded_Rectangle
        (C,
         -50, -50, 100, 100,
         10, 10, 10, 10,
         Solid_Red,
         Black,
         2,
         Shadows => (1 => (Offset_X => 4,
                           Offset_Y => 4,
                           Blur     => 6,
                           Spread   => 0,
                           Inset    => False,
                           Color    => (0,0,0,100))) );

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/rounded_rectangle_2.ppm");

   end Run_Test;

end Rounded_Rectangle_2;