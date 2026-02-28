with AUnit.Assertions;     use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;             use Renderer;
with Renderer.Rectangle;   use Renderer.Rectangle;
with Renderer.Gradients;   use Renderer.Gradients;
with Renderer.Gradients.Constants; use Renderer.Gradients.Constants;
with Renderer.Colors;      use Renderer.Colors;
with Framebuffer;          use Framebuffer;
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
      --  Solid baseline
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 20,
         Y             => Y,
         Width         => 140,
         Height        => 60,
         Radius_TL     => 0,
         Radius_TR     => 0,
         Radius_BR     => 0,
         Radius_BL     => 0,
         Fill_Gradient => Solid_Red,
         Border_Color  => Black,
         Border_Size   => 1,
         Shadows       => Empty_Shadow_Array);

      Y := Y + 90;

      ------------------------------------------------------------------
      --  Per-corner radii
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 20,
         Y             => Y,
         Width         => 160,
         Height        => 80,
         Radius_TL     => 30,
         Radius_TR     => 5,
         Radius_BR     => 40,
         Radius_BL     => 10,
         Fill_Gradient => Solid_Green,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => Empty_Shadow_Array);

      Y := Y + 110;

      ------------------------------------------------------------------
      --  Extreme radius (clamping)
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 20,
         Y             => Y,
         Width         => 80,
         Height        => 60,
         Radius_TL     => 100,
         Radius_TR     => 100,
         Radius_BR     => 100,
         Radius_BL     => 100,
         Fill_Gradient => Solid_Purple,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => Empty_Shadow_Array);

      Y := Y + 100;

      ------------------------------------------------------------------
      --  Thick border
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 20,
         Y             => Y,
         Width         => 160,
         Height        => 80,
         Radius_TL     => 20,
         Radius_TR     => 20,
         Radius_BR     => 20,
         Radius_BL     => 20,
         Fill_Gradient => Solid_White,
         Border_Color  => Black,
         Border_Size   => 12,
         Shadows       => Empty_Shadow_Array);

      Y := Y + 110;

      ------------------------------------------------------------------
      --  Transparent fill (border only)
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 20,
         Y             => Y,
         Width         => 160,
         Height        => 80,
         Radius_TL     => 15,
         Radius_TR     => 15,
         Radius_BR     => 15,
         Radius_BL     => 15,
         Fill_Gradient => Solid_Transparent,
         Border_Color  => Red,
         Border_Size   => 4,
         Shadows       => Empty_Shadow_Array);

      ------------------------------------------------------------------
      --  Linear gradient
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 240,
         Y             => 20,
         Width         => 220,
         Height        => 70,
         Radius_TL     => 15,
         Radius_TR     => 15,
         Radius_BR     => 15,
         Radius_BL     => 15,
         Fill_Gradient => Linear_Red_Blue,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => Empty_Shadow_Array);

      ------------------------------------------------------------------
      --  Radial gradient
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 240,
         Y             => 120,
         Width         => 160,
         Height        => 160,
         Radius_TL     => 30,
         Radius_TR     => 30,
         Radius_BR     => 30,
         Radius_BL     => 30,
         Fill_Gradient => Radial_Test,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => Empty_Shadow_Array);

      ------------------------------------------------------------------
      --  Conic gradient
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 440,
         Y             => 120,
         Width         => 160,
         Height        => 160,
         Radius_TL     => 40,
         Radius_TR     => 40,
         Radius_BR     => 40,
         Radius_BL     => 40,
         Fill_Gradient => Conic_Test,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => Empty_Shadow_Array);

      ------------------------------------------------------------------
      --  Soft shadow
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 240,
         Y             => 320,
         Width         => 160,
         Height        => 70,
         Radius_TL     => 15,
         Radius_TR     => 15,
         Radius_BR     => 15,
         Radius_BL     => 15,
         Fill_Gradient => Solid_Green,
         Border_Color  => Black,
         Border_Size   => 1,
         Shadows       => (1 => (Offset_X => 4,
                                 Offset_Y => 4,
                                 Blur     => 8,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => Shadow_Soft)));

      ------------------------------------------------------------------
      --  Large blur shadow
      ------------------------------------------------------------------

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 440,
         Y             => 320,
         Width         => 160,
         Height        => 70,
         Radius_TL     => 15,
         Radius_TR     => 15,
         Radius_BR     => 15,
         Radius_BL     => 15,
         Fill_Gradient => Solid_White,
         Border_Color  => Black,
         Border_Size   => 1,
         Shadows       => (1 => (Offset_X => 10,
                                 Offset_Y => 10,
                                 Blur     => 30,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => Shadow_Large)));

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/rounded_rectangle_1.ppm");

   end Run_Test;

end Rounded_Rectangle_1;