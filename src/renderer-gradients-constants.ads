package Renderer.Gradients.Constants is

   ------------------------------------------------------------------
   --  Gradients
   ------------------------------------------------------------------
   Solid_Red         : constant Gradient := Solid (Red);
   Solid_Blue        : constant Gradient := Solid (Blue);
   Solid_Green       : constant Gradient := Solid (Green);
   Solid_Purple      : constant Gradient := Solid (Purple);
   Solid_White       : constant Gradient := Solid (White);
   Solid_Black       : constant Gradient := Solid (Black);
   Solid_Gray        : constant Gradient := Solid (Gray);
   Solid_Yellow      : constant Gradient := Solid (Yellow);
   Solid_Transparent : constant Gradient := Solid (Transparent);

   Linear_Red_Blue : constant Gradient :=
     (Stop_Count => 2,
      Kind       => Linear,
      X1         => 240.0,
      Y1         => 20.0,
      X2         => 460.0,
      Y2         => 20.0,
      Stops      =>
        [1 => (Position => 0.0, Color => Red),
         2 => (Position => 1.0, Color => Blue)],
      others     => <>);

   Radial_Test : constant Gradient :=
     (Stop_Count => 2,
      Kind       => Radial,
      CX         => 320.0,
      CY         => 200.0,
      Radius     => 80.0,
      Stops      =>
        [1 => (Position => 0.0, Color => White),
         2 => (Position => 1.0, Color => Black)],
      others     => <>);

   Conic_Test : constant Gradient :=
     (Stop_Count   => 4,
      Kind         => Conic,
      CX           => 520.0,
      CY           => 200.0,
      Angle_Offset => 0.0,
      Stops        =>
        [1 => (Position => 0.0, Color => Red),
         2 => (Position => 0.33, Color => Green),
         3 => (Position => 0.66, Color => Blue),
         4 => (Position => 1.0, Color => Red)],
      others       => <>);

end Renderer.Gradients.Constants;