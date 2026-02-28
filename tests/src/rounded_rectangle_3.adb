with AUnit.Assertions;             use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;                     use Renderer;
with Renderer.Rectangle;           use Renderer.Rectangle;
with Renderer.Colors;              use Renderer.Colors;
with Renderer.Gradients;           use Renderer.Gradients;
with Renderer.Gradients.Constants; use Renderer.Gradients.Constants;
with Framebuffer;                  use Framebuffer;
with IO;

package body Rounded_Rectangle_3 is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Rounded rectangle - shadows");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      C  : Render_Context := Create_Context (900, 600);
      C2 : Render_Context := Create_Context (400, 400);

      procedure Clear_Rect
        (Context : in out Render_Context;
         X, Y    : Integer;
         Width   : Natural;
         Height  : Natural;
         Color   : Pixel)
      is
         G : Gradient (1);
      begin
         G.Kind := Solid;
         G.Stops(G.Stops'First) := (Position => 0.0, Color => Color);

         Draw_Rounded_Rectangle
           (Context       => Context,
            X             => X,
            Y             => Y,
            Width         => Width,
            Height        => Height,
            Radius_TL     => 0,
            Radius_TR     => 0,
            Radius_BR     => 0,
            Radius_BL     => 0,
            Fill_Gradient => G,
            Border_Color  => (0,0,0,0),
            Border_Size   => 0,
            Shadows       => Empty_Shadow_Array);
      end Clear_Rect;

   begin
      ----------------------------------------------------------------
      --  Background 1: White
      ----------------------------------------------------------------
      C.Clear (White);

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 60,
         Y             => 80,
         Width         => 200,
         Height        => 120,
         Radius_TL     => 25,
         Radius_TR     => 25,
         Radius_BR     => 25,
         Radius_BL     => 25,
         Fill_Gradient => Solid_Blue,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 12,
                                 Offset_Y => 12,
                                 Blur     => 20,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => Shadow)) );

      ----------------------------------------------------------------
      --  Background 2: Dark
      ----------------------------------------------------------------
      Clear_Rect (C, 300, 0, 300, 600, (40, 40, 40, 255));

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 340,
         Y             => 100,
         Width         => 200,
         Height        => 120,
         Radius_TL     => 30,
         Radius_TR     => 10,
         Radius_BR     => 30,
         Radius_BL     => 10,
         Fill_Gradient => Solid_Gray,
         Border_Color  => White,
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 15,
                                 Offset_Y => 15,
                                 Blur     => 30,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,180))) );

      ----------------------------------------------------------------
      --  Background 3: Checker Pattern
      ----------------------------------------------------------------
      for Y in 0 .. 599 loop
         for X in 600 .. 899 loop
            if ((X / 20 + Y / 20) mod 2) = 0 then
               C.Put_Pixel (X, Y, (220, 220, 220, 255));
            else
               C.Put_Pixel (X, Y, (180, 180, 180, 255));
            end if;
         end loop;
      end loop;

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 650,
         Y             => 120,
         Width         => 200,
         Height        => 120,
         Radius_TL     => 40,
         Radius_TR     => 40,
         Radius_BR     => 40,
         Radius_BL     => 40,
         Fill_Gradient => Solid_Red,
         Border_Color  => Black,
         Border_Size   => 3,
         Shadows       => (1 => (Offset_X => 10,
                                 Offset_Y => 10,
                                 Blur     => 25,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,120))) );

      ----------------------------------------------------------------
      --  Overlapping Shadows Test
      ----------------------------------------------------------------
      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 150,
         Y             => 300,
         Width         => 200,
         Height        => 120,
         Radius_TL     => 30,
         Radius_TR     => 30,
         Radius_BR     => 30,
         Radius_BL     => 30,
         Fill_Gradient => Solid ((100,200,140,255)),
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 8,
                                 Offset_Y => 8,
                                 Blur     => 20,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,140))) );

      Draw_Rounded_Rectangle
        (Context       => C,
         X             => 220,
         Y             => 340,
         Width         => 200,
         Height        => 120,
         Radius_TL     => 30,
         Radius_TR     => 30,
         Radius_BR     => 30,
         Radius_BL     => 30,
         Fill_Gradient => Solid ((140,120,240,255)),
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 8,
                                 Offset_Y => 8,
                                 Blur     => 20,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,140))) );

      -- Shadow with blur and spread
      Draw_Rounded_Rectangle
        (C, 10, 400, 30, 20,
         Radius_TL => 4,
         Radius_TR => 4,
         Radius_BR => 4,
         Radius_BL => 4,
         Fill_Gradient => Solid_Red,
         Border_Color  => (0,0,0,255),
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 3,
                                 Offset_Y => 3,
                                 Blur     => 5,
                                 Spread   => 2,
                                 Inset    => False,
                                 Color    => (0,0,0,128))) );
IO.Write_PPM (Get_Buffer (C), "output/Rounded_Rectangle_Shadows.ppm");
Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 0,
         Y             => 0,
         Width         => 400,
         Height        => 400,
         Radius_TL     => 0,
         Radius_TR     => 0,
         Radius_BR     => 0,
         Radius_BL     => 0,
         Fill_Gradient => Solid_White,
         Border_Color  => Transparent,
         Border_Size   => 0,
         Shadows       => Empty_Shadow_Array);

Renderer.Rectangle.Draw_Rounded_Rectangle
   (C2,
    50, 50, 200, 100, 20, 20, 20, 20,
    Solid_White,
    (R => 0, G => 0, B => 0, A => 255),
    Border_Size => 4,
    Shadows => (
       1 => (Offset_X => 5,  Offset_Y => 5,  Blur => 10,  Spread => 0,  Inset => False, Color => (0, 0, 0, 100)),
       2 => (Offset_X => -5, Offset_Y => -5, Blur => 15, Spread => 0,  Inset => False, Color => (0, 0, 0, 50)),
       3 => (Offset_X => 10, Offset_Y => -10, Blur => 20, Spread => 5, Inset => False, Color => (255, 0, 0, 80))
    )
);
IO.Write_PPM (Get_Buffer (C2), "output/Rounded_Rectangle_Shadows3.ppm");

      -------------------------------------------------------------------
      --  C2 canvas tests
      ----------------------------------------------------------------
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 0,
         Y             => 0,
         Width         => 400,
         Height        => 400,
         Radius_TL     => 0,
         Radius_TR     => 0,
         Radius_BR     => 0,
         Radius_BL     => 0,
         Fill_Gradient => Solid_White,
         Border_Color  => Transparent,
         Border_Size   => 0,
         Shadows       => Empty_Shadow_Array);

      -- Test 1: Rounded rectangle with shadow only
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 50,
         Y             => 50,
         Width         => 100,
         Height        => 60,
         Radius_TL     => 20,
         Radius_TR     => 20,
         Radius_BR     => 20,
         Radius_BL     => 20,
         Fill_Gradient => Solid_White,
         Border_Color  => Transparent,
         Border_Size   => 0,
         Shadows       => (1 => (Offset_X => 10,
                                 Offset_Y => 10,
                                 Blur     => 16,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,128))) );

      -- Test 2: Rounded rectangle with shadow and border
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 200,
         Y             => 50,
         Width         => 100,
         Height        => 60,
         Radius_TL     => 20,
         Radius_TR     => 20,
         Radius_BR     => 20,
         Radius_BL     => 20,
         Fill_Gradient => Solid_Red,
         Border_Color  => Black,
         Border_Size   => 4,
         Shadows       => (1 => (Offset_X => 8,
                                 Offset_Y => 8,
                                 Blur     => 16,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,128))) );

      -- Test 3: Square rectangle with shadow
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 50,
         Y             => 150,
         Width         => 100,
         Height        => 60,
         Radius_TL     => 0,
         Radius_TR     => 0,
         Radius_BR     => 0,
         Radius_BL     => 0,
         Fill_Gradient => Solid_Gray,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 12,
                                 Offset_Y => 12,
                                 Blur     => 16,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,128))) );

      -- Test 4: Pill shape
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 200,
         Y             => 150,
         Width         => 150,
         Height        => 60,
         Radius_TL     => 30,
         Radius_TR     => 30,
         Radius_BR     => 30,
         Radius_BL     => 30,
         Fill_Gradient => Solid_Red,
         Border_Color  => Black,
         Border_Size   => 3,
         Shadows       => (1 => (Offset_X => 5,
                                 Offset_Y => 5,
                                 Blur     => 24,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,180))) );

      -- Test 5: Transparent rectangle with shadow only
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 50,
         Y             => 250,
         Width         => 100,
         Height        => 60,
         Radius_TL     => 15,
         Radius_TR     => 15,
         Radius_BR     => 15,
         Radius_BL     => 15,
         Fill_Gradient => Solid ((0,0,0,0)),
         Border_Color  => (0,0,0,0),
         Border_Size   => 0,
         Shadows       => (1 => (Offset_X => 8,
                                 Offset_Y => 8,
                                 Blur     => 16,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,128))) );

      -- Test 6: Offsets only, no blur
      Draw_Rounded_Rectangle
        (Context       => C2,
         X             => 200,
         Y             => 250,
         Width         => 120,
         Height        => 60,
         Radius_TL     => 20,
         Radius_TR     => 20,
         Radius_BR     => 20,
         Radius_BL     => 20,
         Fill_Gradient => Solid_White,
         Border_Color  => Black,
         Border_Size   => 2,
         Shadows       => (1 => (Offset_X => 12,
                                 Offset_Y => 12,
                                 Blur     => 0,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,128))) );

      IO.Write_PPM (Get_Buffer (C2), "output/Rounded_Rectangle_Shadows_2.ppm");

   end Run_Test;

end Rounded_Rectangle_3;