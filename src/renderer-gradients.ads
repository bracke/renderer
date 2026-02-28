with Renderer.Colors; use Renderer.Colors;

package Renderer.Gradients is

   type Gradient_Kind is (Solid, Linear, Radial, Conic);

   type Gradient_Stop is record
      Position : Float; -- 0.0 .. 1.0
      Color    : Pixel;
   end record;

   type Gradient_Stop_Array is array (Positive range <>) of Gradient_Stop;

   type Gradient (Stop_Count : Positive) is record
      Kind : Gradient_Kind := Solid;

      --  Linear
      X1, Y1 : Float := 0.0;
      X2, Y2 : Float := 1.0;

      --  Radial
      CX, CY : Float := 0.0;
      Radius : Float := 1.0;

      --  Conic
      Angle_Offset : Float := 0.0;  --  radians

      --  Repeating support
      Repeat        : Boolean := False;   --  true => repeat
      Repeat_Length : Float :=
        0.0;       --  e.g., pixels for linear/radial, radians for conic

      Stops : Gradient_Stop_Array (1 .. Stop_Count);
   end record;

   --
   --  Produce a flat gradient with the given color
   --  Not really a gradient.
   --
   function Solid (C : Pixel) return Gradient;

end Renderer.Gradients;
