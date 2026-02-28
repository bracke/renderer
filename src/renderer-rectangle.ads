with Renderer; use Renderer;
with Renderer.Gradients; use Renderer.Gradients;
with Framebuffer; use Framebuffer;

package Renderer.Rectangle with SPARK_Mode => On is

   -- Single shadow parameters
   type Shadow_Params is record
      Offset_X : Integer;
      Offset_Y : Integer;
      Blur     : Natural;
      Spread   : Natural;
      Color    : Pixel;
      Inset    : Boolean := False;
   end record;

   -- Multiple shadows
   type Shadow_Array is array (Positive range <>) of Shadow_Params;

   Empty_Shadow_Array : constant Shadow_Array(1 .. 0) := (others => <>);

   procedure Draw_Rounded_Rectangle
      (Context       : in out Render_Context;
         X, Y          : Integer;
         Width, Height : Natural;
         Radius_TL, Radius_TR, Radius_BR, Radius_BL : Natural := 0;
         Fill_Gradient : Gradient;
         Border_Color  : Pixel;
         Border_Size   : Natural := 0;
         Shadows       : Shadow_Array := Empty_Shadow_Array);

end Renderer.Rectangle;
