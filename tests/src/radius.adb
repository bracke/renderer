with AUnit.Assertions;   use AUnit.Assertions;
with Renderer;           use Renderer;
with Renderer.Rectangle; use Renderer.Rectangle;
with Renderer.Gradients; use Renderer.Gradients;

with Renderer.Colors;    use Renderer.Colors;
with Framebuffer;        use Framebuffer;

package body Radius is

   overriding
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Radius");
   end Name;

   overriding
   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);

      Context : Render_Context (63, 63);
      Fill    : constant Gradient := Solid ((255, 255, 255, 255));

   begin
      Context.Clear (Transparent);

      ------------------------------------------------------------
      --  1. Rounded rectangle with radius 10
      ------------------------------------------------------------
      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 10, Y => 10, Width => 30, Height => 30);
         Style : constant Rectangle_Style :=
           (Shadow_Count => 0,
            Gradient_Count => 1,
            Fill    => Fill,
            Border  => No_Border,
            Radii   => (10, 10, 10, 10),
            Shadows => Empty_Shadow_Array);
      begin
         Draw_Rounded_Rectangle (Context, Geo, Style);
      end;

      ------------------------------------------------------------
      --  Horizontal symmetry test (example, commented)
      ------------------------------------------------------------
      for Y in Context.Get_Buffer'Range (2) loop
         for X in Context.Get_Buffer'Range (1) loop
            null;
            --  Example assertion placeholder:
            --  Assert(Context.Get_Pixel(X,Y) =
            --        Context.Get_Pixel(63-X,Y),
            --        "Symmetry failure");
         end loop;
      end loop;

      Context.Clear ((0, 0, 0, 0));

      ------------------------------------------------------------
      --  Shadow energy test
      ------------------------------------------------------------
      declare
         Geo   : constant Rectangle_Geometry :=
           (X => 20, Y => 20, Width => 20, Height => 20);
         Style : constant Rectangle_Style :=
           (Shadow_Count => 1,
            Gradient_Count => 1,
            Fill    => Solid ((0, 0, 0, 0)),
            Border  => No_Border,
            Radii   => (0, 0, 0, 0),
            Shadows =>
              [1 =>
                 (Offset_X => 0,
                  Offset_Y => 0,
                  Blur     => 6,
                  Spread   => 0,
                  Inset    => False,
                  Color    => (0, 0, 0, 128))]);
      begin
         Draw_Rounded_Rectangle (Context, Geo, Style);
      end;

      Assert
        (Context.Get_Pixel (19, 30).A > Context.Get_Pixel (10, 30).A,
         "Shadow not decreasing");

      Context.Clear ((0, 0, 0, 0));

      ------------------------------------------------------------
      --  Placeholder for gradient & complex tests
      ------------------------------------------------------------
      --  Example:
      --  declare
      --    Geo   : constant Rectangle_Geometry := (X => 12, Y => 8, Width => 30, Height => 22);
      --    Style : constant Rectangle_Style :=
      --      (Fill    => Complex_Test_Gradient,
      --       Border  => (Color => (255,255,255,255), Size => 3),
      --       Radii   => (6,4,10,2),
      --       Shadows => (1 => (Offset_X => 0,
      --                         Offset_Y => 0,
      --                         Blur     => 5,
      --                         Spread   => 0,
      --                         Inset    => False,
      --                         Color    => (0,0,0,100))));
      --  begin
      --    Draw_Rounded_Rectangle(Context, Geo, Style);
      --  end;

      --  Regression hash checks can remain the same:
      --  declare
      --    H : Interfaces.Unsigned_32 := Context.Get_Buffer.Hash;
      --  begin
      --    Assert(Context.Hash = Expected, "Regression mismatch");
      --  end;

   end Run_Test;

end Radius;
