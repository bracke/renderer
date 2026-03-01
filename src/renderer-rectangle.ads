pragma Ada_2022;
pragma Extensions_Allowed (All_Extensions);
with Renderer;           use Renderer;
with Renderer.Gradients; use Renderer.Gradients;
with Renderer.Gradients.Constants;
with Framebuffer;        use Framebuffer;

package Renderer.Rectangle
  with SPARK_Mode => On
is

   --  Single shadow parameters
   type Shadow_Params is record
      Offset_X : Integer;
      Offset_Y : Integer;
      Blur     : Natural;
      Spread   : Natural;
      Color    : Pixel;
      Inset    : Boolean := False;
   end record;

   --  Multiple shadows
   type Shadow_Array is array (Positive range <>) of Shadow_Params;

   Empty_Shadow_Array : constant Shadow_Array (1 .. 0) := [others => <>];

   type Rectangle_Geometry is record
      X, Y          : Integer;
      Width, Height : Natural;
   end record;

   type Corner_Radii is record
      TL, TR, BR, BL : Natural := 0;
   end record;

   type Border_Style is record
      Color : Pixel;
      Size  : Natural := 0;
   end record;

   No_Border : constant Border_Style :=
     (Color => (R => 0, G => 0, B => 0, A => 0), Size => 0);

   type Rectangle_Style
     (Shadow_Count   : Natural := 0;
      Gradient_Count : Positive := 1)
   is record
      Fill    : Gradient (Gradient_Count);
      Border  : Border_Style := No_Border;
      Shadows : Shadow_Array (1 .. Shadow_Count);
      Radii   : Corner_Radii := (others => 0);
   end record;

   Default_Rect : Rectangle_Style (Shadow_Count => 0, Gradient_Count => 1)
      := (Fill => Renderer.Gradients.Constants.Solid_Black, others => <>);

   procedure Draw_Rounded_Rectangle
     (Context  : in out Render_Context;
      Geometry : Rectangle_Geometry;
      Style    : Rectangle_Style);

end Renderer.Rectangle;
