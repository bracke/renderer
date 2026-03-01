with AUnit.Assertions;             use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;                     use Renderer;
with Renderer.Rectangle;           use Renderer.Rectangle;
with Renderer.Gradients;           use Renderer.Gradients;
with Renderer.Gradients.Constants; use Renderer.Gradients.Constants;
with Renderer.Colors;              use Renderer.Colors;
with Framebuffer;                  use Framebuffer;
with IO;

package body Rounded_Rectangle_1 is

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

      C : Render_Context := Create_Context (600, 400);
      Y : Integer := 20;

   begin
      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");

      ------------------------------------------------------------------
      --  1. Solid baseline
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 20, Y => Y, Width => 140, Height => 60),
         Style    =>
           Rectangle_Style'
             (Gradient_Count => 1,
              Shadow_Count   => 0,
              Fill           => Solid_Red,
              Border         => Border_Style'(Black, 0),
              Radii          => (0, 0, 0, 0),
              Shadows        => Empty_Shadow_Array,
              others         => <>));

      Y := Y + 90;

      ------------------------------------------------------------------
      --  2. Per-corner radii
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 20, Y => Y, Width => 160, Height => 80),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 1,
              Fill         => Solid_Green,
              Border       => Border_Style'(Black, 0),
              Radii        => (30, 5, 40, 10),
              Shadows      => Empty_Shadow_Array,
              others => <>));

      Y := Y + 110;

      ------------------------------------------------------------------
      --  3. Extreme radius (clamping)
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 20, Y => Y, Width => 80, Height => 60),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 1,
              Fill         => Solid_Purple,
              Border       => Border_Style'(Black, 0),
              Radii        => (100, 100, 100, 100),
              Shadows      => Empty_Shadow_Array,
              others => <>));

      Y := Y + 100;

      ------------------------------------------------------------------
      --  4. Thick border
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 20, Y => Y, Width => 160, Height => 80),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 1,
              Fill         => Solid_White,
              Border       => Border_Style'(Black, 12),
              Radii        => (20, 20, 20, 20),
              Shadows      => Empty_Shadow_Array,
              others => <>));

      Y := Y + 110;

      ------------------------------------------------------------------
      --  5. Transparent fill (border only)
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 20, Y => Y, Width => 160, Height => 80),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 1,
              Fill         => Solid_Transparent,
              Border       => Border_Style'(Red, 1),
              Radii        => (15, 15, 15, 15),
              Shadows      => Empty_Shadow_Array,
              others => <>));

      ------------------------------------------------------------------
      --  6. Linear gradient
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 240, Y => 20, Width => 220, Height => 70),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 2,
              Fill         => Linear_Red_Blue,
              Border       => Border_Style'(Black, 1),
              Radii        => (15, 15, 15, 15),
              Shadows      => Empty_Shadow_Array,
              others => <>));

      ------------------------------------------------------------------
      --  7. Radial gradient
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 240, Y => 120, Width => 160, Height => 160),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 2,
              Fill         => Radial_Test,
              Border       => Border_Style'(Black, 1),
              Radii        => (30, 30, 30, 30),
              Shadows      => Empty_Shadow_Array,
              others => <>));

      ------------------------------------------------------------------
      --  8. Conic gradient
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 440, Y => 120, Width => 160, Height => 160),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 0,
              Gradient_Count => 4,
              Fill         => Conic_Test,
              Border       => Border_Style'(Black, 1),
              Radii        => (40, 40, 40, 40),
              Shadows      => Empty_Shadow_Array,
              others => <>
            ));

      ------------------------------------------------------------------
      --  9. Soft shadow
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 240, Y => 320, Width => 160, Height => 70),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 1,
              Gradient_Count => 1,
              Fill         => Solid_Green,
              Border       => Border_Style'(Black, 1),
              Radii        => (15, 15, 15, 15),
              Shadows      =>
                (1 =>
                   (Offset_X => 4,
                    Offset_Y => 4,
                    Blur     => 8,
                    Spread   => 0,
                    Inset    => False,
                    Color    => Shadow_Soft))));

      ------------------------------------------------------------------
      -- 10. Large blur shadow
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (C,
         Geometry => (X => 440, Y => 320, Width => 160, Height => 70),
         Style    =>
           Rectangle_Style'
             (Shadow_Count => 1,
              Gradient_Count => 1,
              Fill         => Solid_White,
              Border       => Border_Style'(Black, 1),
              Radii        => (15, 15, 15, 15),
              Shadows      =>
                (1 =>
                   (Offset_X => 10,
                    Offset_Y => 10,
                    Blur     => 30,
                    Spread   => 0,
                    Inset    => False,
                    Color    => Shadow_Large))));

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/rounded_rectangle_1.ppm");

   end Run_Test;

end Rounded_Rectangle_1;
