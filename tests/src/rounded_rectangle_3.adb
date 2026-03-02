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

      ------------------------------------------------------------
      --  Clear_Rect helper
      ------------------------------------------------------------
      procedure Clear_Rect
        (Context : in out Render_Context;
         X, Y    : Integer;
         Width   : Natural;
         Height  : Natural;
         Color   : Pixel)
      is
         G     : constant Gradient := Solid (Color);
         Geo   : constant Rectangle_Geometry :=
           (X => X, Y => Y, Width => Width, Height => Height);
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

      C.Clear (White);

      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 60, Y => 80, Width => 200, Height => 120);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 1,
            Gradient_Count => 1,
            Fill           => Solid_Blue,
            Border         => (Color => Black, Size => 2),
            Radii          => (25, 25, 25, 25),
            Shadows        =>
              [1 =>
                 (Offset_X => 12,
                  Offset_Y => 12,
                  Blur     => 20,
                  Spread   => 0,
                  Inset    => False,
                  Color    => Shadow)]);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      Clear_Rect (C, 300, 0, 300, 600, (40, 40, 40, 255));

      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 340, Y => 100, Width => 200, Height => 120);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 1,
            Gradient_Count => 1,
            Fill           => Solid_Gray,
            Border         => (Color => White, Size => 2),
            Radii          => (30, 10, 30, 10),
            Shadows        =>
              [1 =>
                 (Offset_X => 15,
                  Offset_Y => 15,
                  Blur     => 30,
                  Spread   => 0,
                  Inset    => False,
                  Color    => (0, 0, 0, 180))]);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      for Y_Pos in 0 .. 599 loop
         for X_Pos in 600 .. 899 loop
            if ((X_Pos / 20 + Y_Pos / 20) mod 2) = 0 then
               C.Put_Pixel (X_Pos, Y_Pos, (220, 220, 220, 255));
            else
               C.Put_Pixel (X_Pos, Y_Pos, (180, 180, 180, 255));
            end if;
         end loop;
      end loop;

      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 650, Y => 120, Width => 200, Height => 120);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 1,
            Gradient_Count => 1,
            Fill           => Solid_Red,
            Border         => (Color => Black, Size => 3),
            Radii          => (40, 40, 40, 40),
            Shadows        =>
              [1 =>
                 (Offset_X => 10,
                  Offset_Y => 10,
                  Blur     => 25,
                  Spread   => 0,
                  Inset    => False,
                  Color    => (0, 0, 0, 120))]);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      Clear_Rect (C2, 0, 0, 400, 400, Renderer.Colors.White);
      ------------------------------------------------------------
      --  C2 small rects
      ------------------------------------------------------------
      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 50, Y => 50, Width => 150, Height => 100);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 1,
            Gradient_Count => 1,
            Fill           => Solid_Green,
            Border         => (Color => Black, Size => 2),
            Radii          => (15, 15, 15, 15),
            Shadows        =>
              [1 =>
                 (Offset_X => 6,
                  Offset_Y => 6,
                  Blur     => 12,
                  Spread   => 0,
                  Inset    => False,
                  Color    => Shadow)]);
      begin
         Draw_Rounded_Rectangle (C2, Geo, Style);
      end;

      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 220, Y => 60, Width => 100, Height => 150);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 0,
            Gradient_Count => 1,
            Fill           => Solid_White,
            Border         => No_Border,
            Radii          => (20, 20, 20, 20),
            Shadows        => Empty_Shadow_Array);
      begin
         Draw_Rounded_Rectangle (C2, Geo, Style);
      end;

      ------------------------------------------------------------
      --  partially transparent shadow
      ------------------------------------------------------------
      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 120, Y => 300, Width => 180, Height => 120);
         Style : constant Rectangle_Style :=
           (Shadow_Count   => 1,
            Gradient_Count => 1,
            Fill           => Renderer.Gradients.Constants.Solid_Yellow,
            Border         => (Color => Black, Size => 3),
            Radii          => (10, 10, 10, 10),
            Shadows        =>
              [1 =>
                 (Offset_X => 8,
                  Offset_Y => 8,
                  Blur     => 15,
                  Spread   => 0,
                  Inset    => False,
                  Color    => (0, 0, 0, 128))]);
      begin
         Draw_Rounded_Rectangle (C, Geo, Style);
      end;

      IO.Write_PPM (Get_Buffer (C), "output/Rounded_Rectangle_Shadows.ppm");
      IO.Write_PPM (Get_Buffer (C2), "output/Rounded_Rectangle_Shadows_2.ppm");

   end Run_Test;

end Rounded_Rectangle_3;
