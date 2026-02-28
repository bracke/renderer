with Ada.Text_IO;

package body Framebuffer is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   --
   --  Is the framebuffer empty which means all pixel are black
   --
   function Is_Empty (B : Buffer) return Boolean is
   begin
      for Y in B'Range (2) loop
         for X in B'Range (1) loop
            if B (X, Y) /= Zero_Pixel then
               return False;
            end if;
         end loop;
      end loop;
      return True;
   end Is_Empty;

   --
   --  Clear framebuffer by settings all pixels to the given Pixel
   --
   procedure Clear (B : in out Buffer; Color : Pixel := Zero_Pixel) is
   begin
      for Y in B'Range (2) loop
         for X in B'Range (1) loop
            B (X, Y) := Color;
         end loop;
      end loop;
   end Clear;

   --
   --  Log the buffer contents to the console
   --
   procedure Dump (B : Buffer) is
   begin
      for Y in B'Range (2) loop
         for X in B'Range (1) loop
            if B (X, Y).R /= 0 or else B (X, Y).G /= 0 or else B (X, Y).B /= 0
            then
               Log
                 ("Pixel at ("
                  & X'Image
                  & ", "
                  & Y'Image
                  & "): "
                  & "R="
                  & B (X, Y).R'Image
                  & ", G="
                  & B (X, Y).G'Image
                  & ", B="
                  & B (X, Y).B'Image);
            end if;
         end loop;
      end loop;
   end Dump;

   --
   --  Minimal Hash Function
   --
   function Hash (B : Buffer) return Interfaces.Unsigned_32 is
      use Interfaces;

      H : Unsigned_32 := 2166136261; -- FNV offset basis
   begin
       for Y in B'Range (2) loop
         for X in B'Range (1) loop
            declare
               P : Pixel := B (X, Y);
            begin
               H := (H xor Unsigned_32(P.R)) * 16777619;
               H := (H xor Unsigned_32(P.G)) * 16777619;
               H := (H xor Unsigned_32(P.B)) * 16777619;
               H := (H xor Unsigned_32(P.A)) * 16777619;
            end;
         end loop;
      end loop;
      return H;
   end Hash;

end Framebuffer;
