package Renderer.Colors is

   ------------------------------------------------------------------
   --  Colors
   ------------------------------------------------------------------
   Black          : constant Pixel := (R => 0, G => 0, B => 0, A => 255);
   White          : constant Pixel := (R => 255, G => 255, B => 255, A => 255);
   Red            : constant Pixel := (R => 255, G => 0, B => 0, A => 255);
   Green          : constant Pixel := (R => 0, G => 200, B => 120, A => 255);
   Yellow         : constant Pixel := (255, 255, 0, 255);
   Blue           : constant Pixel := (R => 0, G => 0, B => 255, A => 255);
   Purple         : constant Pixel := (R => 120, G => 80, B => 255, A => 255);
   Gray           : constant Pixel := (200, 200, 200, 255);
   Transparent    : constant Pixel := (R => 0, G => 0, B => 0, A => 0);
   Shadow_Soft    : constant Pixel := (R => 0, G => 0, B => 0, A => 120);
   Shadow_Large   : constant Pixel := (R => 0, G => 0, B => 0, A => 100);
   Shadow         : constant Pixel := (0, 0, 0, 160);

   --  Solid “Bootstrap Primary” color
   Primary_Blue : constant Pixel := (R => 13, G => 110, B => 253, A => 255);

   --  Slightly darker border
   Primary_Border : constant Pixel :=
        (R => 10, G => 82, B => 230, A => 255);

   --  Shadow color (semi‑transparent black)
   Shadow_Col : constant Pixel := (R => 0, G => 0, B => 0, A => 80);

end Renderer.Colors;