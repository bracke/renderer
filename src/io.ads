with Framebuffer; use Framebuffer;

package IO is

   type Byte_Array is array (Natural range <>) of Byte;

   --
   --  Write buffer to file using PPM format
   --
   procedure Write_PPM (B : Buffer; Filename : String);

   --
   --  Write buffer to string using PPM format
   --
   function Write_PPM (B : Buffer) return String;

   --
   --  Write buffer to Byte_Arrav using PPM format
   --
   function Write_PPM (B : Buffer) return Byte_Array;

   --
   --  Read PPM from a Byte_Array into a framebuffer
   --
   procedure Read_PPM (Data : Byte_Array; B : in out Buffer);

   --
   --  Read PPM file into a Buffer
   --
   function Read_PPM (Filename : String) return Buffer;


end IO;