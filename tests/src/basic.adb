with AUnit.Assertions;     use AUnit.Assertions;
with Renderer;             use Renderer;
with Renderer.Rectangle;   use Renderer.Rectangle;
with Renderer.Gradients;   use Renderer.Gradients;
with Interfaces;
with Renderer.Colors;      use Renderer.Colors;
with Framebuffer;          use Framebuffer;

package body Basic is

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Basic");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      Context : Render_Context (63, 63);

      Fill : constant Gradient (1) :=
       (Stop_Count => 1,
         Kind  => Solid,
         Stops => [1 => (Position => 0.0,
                        Color => (R => 255, G => 0, B => 0, A => 255))],
         others => <>
      );

   begin
      -------------------------------------------------
      --  Initialize clip
      -------------------------------------------------

      Context.Push_Clip_Rect (
         X_Min => 0,
         Y_Min => 0,
         X_Max => 63,
         Y_Max => 63
      );

      -------------------------------------------------
      --  Clear buffer to transparent
      -------------------------------------------------

      for Y in 0 .. Context.Max_Y loop
         for X in 0 .. Context.Max_X loop
            Context.Put_Pixel (X, Y, Transparent);
         end loop;
      end loop;

      -------------------------------------------------
      --  Call procedure under test
      -------------------------------------------------

      Draw_Rounded_Rectangle
         (Context         => Context,
         X               => 10,
         Y               => 10,
         Width           => 20,
         Height          => 20,
         Fill_Gradient   => Fill,
         Border_Color    => Transparent);

      -------------------------------------------------
      --  Assertions
      -------------------------------------------------
      declare
         Inside  : constant Pixel := Context.Get_Pixel (15, 15);
         Outside : constant Pixel := Context.Get_Pixel (5, 5);
         Filled_Count : Natural := 0;
         H : Interfaces.Unsigned_32 := Context.Get_Buffer.Hash;
      begin
         --  Interior should be red and opaque
         Assert (Inside.R = 255, "Interior should be red and opaque");
         Assert (Inside.G = 0, "Interior should be red and opaque");
         Assert (Inside.B = 0, "Interior should be red and opaque");
         Assert (Inside.A = 255, "Interior should be red and opaque");

         --  Outside should remain untouched
         Assert (Outside.A = 0, "Outside should remain untouched");

         for Y in 0 .. 63 loop
            for X in 0 .. 63 loop
               if Context.Get_Pixel (X, Y).A /= 0 then
                  Filled_Count := Filled_Count + 1;
               end if;
            end loop;
         end loop;

         Assert (Filled_Count > 350, "Filled_Count should approximate 20x20");
      end;

   end Run_Test;

end Basic;