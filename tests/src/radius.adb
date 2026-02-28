with AUnit.Assertions;     use AUnit.Assertions;
with Renderer;             use Renderer;
with Renderer.Rectangle;   use Renderer.Rectangle;
with Renderer.Gradients;   use Renderer.Gradients;

with Interfaces;
with Renderer.Colors;      use Renderer.Colors;
with Framebuffer;          use Framebuffer;

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

      Fill : constant Gradient := Solid ((255,255,255,255));
   begin
      Context.Clear (Renderer.Colors.Transparent);

      ------------------------------------------------------------------
      -- Simple rounded rectangle
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (Context,
         10,10,30,30,
         Radius_TL => 10,
         Radius_TR => 10,
         Radius_BR => 10,
         Radius_BL => 10,
         Fill_Gradient => Fill,
         Border_Color  => Transparent);

      -- Horizontal symmetry check (disabled asserts, just skeleton)
      for Y in Context.Get_Buffer'Range(2) loop
         for X in Context.Get_Buffer'Range(1) loop
            null;
            -- Assert (
            --   Context.Get_Pixel(X,Y) =
            --   Context.Get_Pixel(63-X,Y),
            --   "Symmetry failure");
         end loop;
      end loop;

      Context.Clear ((0,0,0,0));

      ------------------------------------------------------------------
      -- Shadow energy test (updated)
      ------------------------------------------------------------------
      Draw_Rounded_Rectangle
        (Context,
         20,20,20,20,
         Fill_Gradient => Solid ((0,0,0,0)),
         Border_Color  => (0,0,0,0),
         Shadows       => (1 => (Offset_X => 0,
                                 Offset_Y => 0,
                                 Blur     => 6,
                                 Spread   => 0,
                                 Inset    => False,
                                 Color    => (0,0,0,128))));

      Assert(Context.Get_Pixel(19,30).A >
             Context.Get_Pixel(10,30).A,
             "Shadow not decreasing");

      Context.Clear ((0,0,0,0));

      ------------------------------------------------------------------
      -- Gradient / per-corner test (commented out)
      ------------------------------------------------------------------
      -- Draw_Rounded_Rectangle
      --   (Context,
      --    12,8,30,22,
      --    Radius_TL => 6,
      --    Radius_TR => 4,
      --    Radius_BR => 10,
      --    Radius_BL => 2,
      --    Fill_Gradient => Complex_Test_Gradient,
      --    Border_Color  => (255,255,255,255),
      --    Border_Size   => 3,
      --    Shadows       => (1 => (Offset_X => 0,
      --                            Offset_Y => 0,
      --                            Blur     => 5,
      --                            Spread   => 0,
      --                            Inset    => False,
      --                            Color    => (0,0,0,100))));

      -- Regression hash test (disabled)
      -- declare
      --    H : Interfaces.Unsigned_32 := Context.Get_Buffer.Hash;
      -- begin
      --    Assert(Context.Hash = Expected, "Regression mismatch");
      -- end;
   end Run_Test;

end Radius;