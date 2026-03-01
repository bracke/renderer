with AUnit.Assertions;   use AUnit.Assertions;
with Ada.Text_IO;
with Renderer;           use Renderer;
with Renderer.Rectangle; use Renderer.Rectangle;
with Renderer.Gradients; use Renderer.Gradients;
with Renderer.Colors;    use Renderer.Colors;
with Framebuffer;        use Framebuffer;
with IO;

package body Bootstrap is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Bootstrap");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      C : Render_Context := Create_Context (600, 700);

      type Button_Style_Record is record
         Fill   : Pixel;
         Border : Pixel;
      end record;

      Button_Styles : constant array (1 .. 8) of Button_Style_Record :=
        [(Fill   => (R => 13, G => 110, B => 253, A => 255),
          Border => (R => 10, G => 82, B => 230, A => 255)), -- Primary
         (Fill   => (R => 108, G => 117, B => 125, A => 255),
          Border => (R => 90, G => 100, B => 110, A => 255)), -- Secondary
         (Fill   => (R => 25, G => 135, B => 84, A => 255),
          Border => (R => 20, G => 110, B => 70, A => 255)), -- Success
         (Fill   => (R => 220, G => 53, B => 69, A => 255),
          Border => (R => 190, G => 45, B => 60, A => 255)), -- Danger
         (Fill   => (R => 255, G => 193, B => 7, A => 255),
          Border => (R => 230, G => 170, B => 6, A => 255)), -- Warning
         (Fill   => (R => 13, G => 202, B => 240, A => 255),
          Border => (R => 10, G => 170, B => 200, A => 255)), -- Info
         (Fill   => (R => 248, G => 249, B => 250, A => 255),
          Border => (R => 220, G => 220, B => 220, A => 255)), -- Light
         (Fill   => (R => 33, G => 37, B => 41, A => 255),
          Border => (R => 20, G => 25, B => 30, A => 255))]; -- Dark

      Start_X       : constant Integer := 10;
      Start_Y       : constant Integer := 10;
      Button_Width  : constant Natural := 160;
      Button_Height : constant Natural := 48;
      R             : constant Natural := 6;
      Shadow        : constant Pixel := (R => 0, G => 0, B => 0, A => 80);

   begin
      C.Clear;
      Assert (Get_Buffer (C).Is_Empty, "Framebuffer should be empty");

      --  Draw a white background
      Draw_FilledRectangle (C, 0, 0, 600, 700, White);

      for I in Button_Styles'Range loop
         Draw_Rounded_Rectangle
           (Context  => C,
            Geometry =>
              (X      => Start_X,
               Y      => Start_Y + Integer (I - 1) * (Button_Height + 16),
               Width  => Button_Width,
               Height => Button_Height),
            Style    =>
              Rectangle_Style'
                (Shadow_Count   => 1,
                 Gradient_Count => 1,
                 Fill           => Solid (Button_Styles (I).Fill),
                 Border         => Border_Style'(Button_Styles (I).Border, 1),
                 Radii         => (R, R, R, R),
                 Shadows        =>
                   [1 =>
                      (Offset_X => 0,
                       Offset_Y => 2,
                       Blur     => 8,
                       Spread   => 0,
                       Inset    => False,
                       Color    => Shadow)]));
      end loop;

      Assert (not Get_Buffer (C).Is_Empty, "Framebuffer should NOT be empty");
      IO.Write_PPM (Get_Buffer (C), "output/bootstrap.ppm");

   end Run_Test;

end Bootstrap;
