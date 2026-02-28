with Interfaces;

package Framebuffer with SPARK_Mode => On is

   type Byte is mod 2**8;
   type Pixel is record
      R, G, B : Byte := 0;
      A       : Byte := 255;
   end record;

   Zero_Pixel : constant Pixel := (R => 0, G => 0, B => 0, A => 255);
   Transparent_Pixel : constant Pixel :=  (R => 0, G => 0, B => 0, A => 0);

   type Pixel_Array is array (Natural range <>, Natural range <>) of Pixel;

   --  type Buffer is new Pixel_Array;
   type Buffer is array (Natural range <>, Natural range <>) of Pixel;

   --
   --  Is the framebuffer empty which means all pixel are black
   --
   function Is_Empty (B : Buffer) return Boolean;

   --
   --  Clear framebuffer by settings all pixels to the given Pixel
   --
   procedure Clear (B : in out Buffer; Color : Pixel := Zero_Pixel);

   --
   --  Log the buffer contents to the console
   --
   procedure Dump (B : Buffer);

   --
   --  Minimal Hash Function
   --
   function Hash (B : Buffer) return Interfaces.Unsigned_32;

end Framebuffer;