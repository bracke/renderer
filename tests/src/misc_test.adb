with AUnit.Assertions;     use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;             use Renderer;
with Renderer.Rectangle;   use Renderer.Rectangle;
with Renderer.Gradients;   use Renderer.Gradients;
with Renderer.Gradients.Constants; use Renderer.Gradients.Constants;
with Renderer.Colors;      use Renderer.Colors;
with Framebuffer;          use Framebuffer;
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

      Solid_Gradient  : constant Gradient :=
        (Stop_Count => 1,
         Kind       => Solid,
         Stops      =>
           [1 =>
              (Position => 0.0,
               Color    => (R => 40, G => 44, B => 52, A => 255))],
         others     => <>);

      Linear_Gradient : constant Gradient :=
        (Stop_Count => 2,
         Kind       => Linear,
         X1         => Float (120),
         Y1         => Float (10),
         X2         => Float (170),
         Y2         => Float (10),
         Repeat       => True,
         Repeat_Length => 20.0,   -- pixels per stripe
         Stops      =>
           [1 => (0.0, (255, 0, 0, 255)), 2 => (1.0, (255, 255, 255, 255))],
         others     => <>);

      Radial_Gradient : constant Gradient :=
        (Stop_Count => 2,
         Kind       => Radial,
         CX         => Float (245),
         CY         => Float (60),
         Radius     => 25.0,
         Repeat        => True,
         Repeat_Length => 30.0,  -- 30px per ring
         Stops      =>
           [1 => (0.0, (0, 0, 255, 255)), 2 => (1.0, (255, 255, 255, 255))],
         others     => <>);

      Conic_Gradient  : constant Gradient :=
        (Stop_Count   => 6,
         Kind         => Conic,
         CX           => 35.0,
         CY           => 200.0,
         Angle_Offset => 0.0,
         Repeat        => True,
         Repeat_Length => Ada.Numerics.Pi / 2.0, -- repeat every 90°
         Stops        =>
           [1 => (0.0, (255, 0, 0, 255)),
            2 => (0.2, (255, 255, 0, 255)),
            3 => (0.4, (0, 255, 0, 255)),
            4 => (0.6, (0, 255, 255, 255)),
            5 => (0.8, (0, 0, 255, 255)),
            6 => (1.0, (255, 0, 0, 255))],
         others     => <>
      );

   begin
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      IO.Write_PPM (Get_Buffer (C), "output/blank.ppm");

      Draw_Line (C, 50, 10, 50, 100, Red);  -- Perfectly vertical
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/vertical_line.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_Rectangle (C, 10, 10, 50, 30, White);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/empty_rectangle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_FilledRectangle (C, 10, 10, 50, 30, Blue);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/filled_rectangle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_Circle (C, 50, 30, 10, Blue);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/circle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      declare
         Polygon_Points : constant Point_Array (1 .. 5) :=
           [(10, 10), (50, 20), (80, 60), (30, 70), (5, 40)];
      begin
         Draw_Polygon (C, Polygon_Points, Red);
         Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
         IO.Write_PPM (Get_Buffer (C), "output/Polygon.ppm");

         C.Clear;
         Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
         Draw_FilledPolygon (C, Polygon_Points, Red);
         Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
         IO.Write_PPM (Get_Buffer (C), "output/Filled_Polygon.ppm");
      end;

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_Triangle (C, 100, 100, 150, 180, 200, 120, Green);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/triangle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_FilledTriangle (C, 100, 100, 150, 180, 200, 120, Green);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/Filled_triangle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_Circle (C, 100, 100, 50, Blue);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/circle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");
      Draw_FilledCircle (C, 100, 100, 50, Blue);
      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/filled_circle.ppm");

      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");

      -- Rounded rectangles using new Shadows array
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C, 10, 10, 50, 100, 20, 20, 20, 20, Solid_Gradient, Green, 10);
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C, 120, 10, 50, 100, 20, 20, 20, 20, Linear_Gradient, Green, 10);
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C, 220, 10, 50, 100, 20, 20, 20, 20, Radial_Gradient, Green, 10);

      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C, 300, 10, 50, 100, 0, 0, 0, 0, Solid_Gradient, Green, 10);
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C, 400, 10, 50, 100, 20, 20, 20, 20, Solid_Gradient, Green, 0);
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C, 500, 10, 50, 100, 20, 20, 20, 20, Solid_Gradient, Green, 1);

      -- Rounded rectangle with shadow using Shadows array
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C,
         10,
         150,
         50,
         250,
         20, 20, 20, 20,
         Conic_Gradient,
         Green,
         10,
         Shadows => (1 => (Offset_X => 0,
                            Offset_Y => 6,
                            Blur     => 20,
                            Spread   => 0,
                            Inset    => False,
                            Color    => (0,0,0,120))));

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/filled_rounded_rectangle_2.ppm");

      C2.Clear;
      Assert (Get_Buffer (C2).Is_Empty, "Framebuffer should be empty");
      Draw_FilledRectangle (C2, 0, 0, 800, 600, White);
      Assert (not Get_Buffer (C2).Is_Empty, "Framebuffer should NOT be empty");

      -- Another rectangle with shadow using Shadows array
      Renderer.Rectangle.Draw_Rounded_Rectangle
        (C2,
         50, 50, 200, 100, 20, 20, 20, 20,
         Solid_White,
         (R => 0, G => 0, B => 0, A => 255),
         Border_Size => 4,
         Shadows => (1 => (Offset_X => 10,
                            Offset_Y => 10,
                            Blur     => 15,
                            Spread   => 0,
                            Inset    => False,
                            Color    => (0,0,0,180))));

      IO.Write_PPM (Get_Buffer (C2), "output/rectangle_width_shadow.ppm");

      C2.Clear;
      Assert (Get_Buffer (C2).Is_Empty, "Framebuffer should be empty");
      Draw_FilledRectangle (C2, 0, 0, 800, 600, White);

   end Run_Test;

end Misc_Test;