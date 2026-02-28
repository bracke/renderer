package body Renderer.Gradients is

   --
   --  Simple helper to create solid gradient
   --  Not really a gradient.
   --
   function Solid (C : Pixel) return Gradient is
      Stop : Gradient_Stop;
      G    : Gradient (1);
   begin
      Stop.Position := 0.0;
      Stop.Color    := C;

      G.Stops := [1 .. 1 => Stop];
      G.Kind := Solid;
      G.Repeat := False;
      G.Repeat_Length := 0.0;
      return G;
   end Solid;

end Renderer.Gradients;