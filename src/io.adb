with Ada.Strings.Maps;           use Ada.Strings.Maps;
with Ada.Strings.Maps.Constants; use Ada.Strings.Maps.Constants;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Streams.Stream_IO;      use Ada.Streams.Stream_IO;

package body IO is

   --
   --  Write buffer to file using PPM format
   --
   procedure Write_PPM (B : Buffer; Filename : String) is

      function Natural_To_String (Value : Natural) return String is
      begin
         if Value < 10 then
            return [1 => Character'Val (Character'Pos ('0') + Value)];
         else
            return Natural_To_String (Value / 10) & Character'Val (Character'Pos ('0') + (Value mod 10));
         end if;
      end Natural_To_String;

      File : Ada.Streams.Stream_IO.File_Type;
      S : Ada.Streams.Stream_IO.Stream_Access;
   begin
      Create (File, Out_File, Filename);
      S := Stream (File);

      --  Write the PPM header as ASCII text
      String'Write (S, "P6" & ASCII.LF);
      String'Write (
      S,
      Natural_To_String (B'Length (1)) & " " & Natural_To_String (B'Length (2)) & ASCII.LF
      );
      String'Write (S, "255" & ASCII.LF);

      --  Write the pixel data as raw bytes
      for Y in B'Range (2) loop
         for X in B'Range (1) loop
            Byte'Write (S, B (X, Y).R);
            Byte'Write (S, B (X, Y).G);
            Byte'Write (S, B (X, Y).B);
         end loop;
      end loop;

      Close (File);
   end Write_PPM;

   --
   --  Write buffer to string using PPM format
   --
   function Write_PPM (B : Buffer) return String is
      Width             : constant Natural := B'Length (1);
      Height            : constant Natural := B'Length (2);
      Max_Color_Value   : constant String := "255";
      Format_Binary_RGB : constant String := "P6";
      Header            : constant String :=
        Format_Binary_RGB
        & ASCII.LF
        & Width'Image
        & " "
        & Height'Image
        & ASCII.LF
        & Max_Color_Value
        & ASCII.LF;
      Pixel_Size        : constant Natural := 3;
      Result            :
        String (1 .. Header'Length + Pixel_Size * Width * Height);
      Offset            : Natural := Header'Length;
   begin
      --  Copy header into result
      Result (1 .. Header'Length) := Header;

      --  Append pixel data
      for Y in B'Range (2) loop
         for X in B'Range (1) loop
            Offset := Offset + 1;
            Result (Offset) := Character'Val (B (X, Y).R);
            Offset := Offset + 1;
            Result (Offset) := Character'Val (B (X, Y).G);
            Offset := Offset + 1;
            Result (Offset) := Character'Val (B (X, Y).B);
         end loop;
      end loop;
      return Result;
   end Write_PPM;

   function Natural_To_Bytes (Value : Natural) return Byte_Array is
      function To_Bytes_Helper
        (Value : Natural; Result : Byte_Array) return Byte_Array is
      begin
         if Value = 0 then
            if Result'Length = 0 then
               return [1 => Byte (Character'Pos ('0'))];
            else
               return Result;
            end if;
         else
            return
              To_Bytes_Helper
                (Value / 10,
                 (1 => Byte (Character'Pos ('0') + (Value mod 10))) & Result);
         end if;
      end To_Bytes_Helper;
   begin
      return To_Bytes_Helper (Value, [1 .. 0 => <>]);
   end Natural_To_Bytes;

   function Get_Pixel_Bytes (B : Buffer) return Byte_Array is
      Width  : constant Natural := B'Length (1);
      Height : constant Natural := B'Length (2);
      Pixels : Byte_Array (1 .. 3 * Width * Height);
      Offset : Natural := 0;
   begin
      for Y in B'Range (2) loop
         for X in B'Range (1) loop
            Offset := Offset + 1;
            Pixels (Offset) := B (X, Y).R;
            Offset := Offset + 1;
            Pixels (Offset) := B (X, Y).G;
            Offset := Offset + 1;
            Pixels (Offset) := B (X, Y).B;
         end loop;
      end loop;
      return Pixels;
   end Get_Pixel_Bytes;

   --
   --  Write buffer to Byte_Arrav using PPM format
   --
   function Write_PPM (B : Buffer) return Byte_Array is
      Width  : constant Natural := B'Length (1);
      Height : constant Natural := B'Length (2);
   begin
      return
        [Character'Pos ('P'), Character'Pos ('6'), Character'Pos (ASCII.LF)]
        & Natural_To_Bytes (Width)
        & (1 => Character'Pos (' '))
        & Natural_To_Bytes (Height)
        & (Character'Pos (ASCII.LF),
           Character'Pos ('2'),
           Character'Pos ('5'),
           Character'Pos ('5'),
           Character'Pos (ASCII.LF))
        & Get_Pixel_Bytes (B);
   end Write_PPM;

   --
   --  Read PPM from a Byte_Array into a framebuffer
   --
   procedure Read_PPM (Data : Byte_Array; B : in out Buffer) is

      P6_Magic   : constant Byte_Array :=
        [Character'Pos ('P'), Character'Pos ('6')];
      Whitespace : constant Character_Set :=
        To_Set (' ' & ASCII.LF & ASCII.HT & ASCII.CR);
      DigitSet   : constant Character_Set := Decimal_Digit_Set;

      procedure Skip_Whitespace (Index : in out Natural) is
      begin
         while Index <= Data'Last
           and then Is_In (Character'Val (Data (Index)), Whitespace)
         loop
            Index := Index + 1;
         end loop;
      end Skip_Whitespace;

      function Parse_Number
        (Data : Byte_Array; Index : in out Natural) return Natural
      is
         Value : Natural := 0;
      begin
         Skip_Whitespace (Index);
         while Index <= Data'Last
           and then Is_In (Character'Val (Data (Index)), DigitSet)
         loop
            Value := Value * 10 + Integer (Data (Index) - Character'Pos ('0'));
            Index := Index + 1;
         end loop;
         return Value;
      end Parse_Number;

      procedure Read_Header
        (Data   : Byte_Array;
         Index  : in out Natural;
         Width  : out Natural;
         Height : out Natural) is
      begin
         --  Check magic number ("P6")
         if Index + 1 > Data'Last or else Data (Index .. Index + 1) /= P6_Magic
         then
            raise Constraint_Error with "Invalid PPM magic number";
         end if;
         Index := Index + 2;  --  Skip "P6"

         --  Parse width and height
         Skip_Whitespace (Index);
         Width := Parse_Number (Data, Index);
         Height := Parse_Number (Data, Index);

         --  Skip max color value ("255")
         Skip_Whitespace (Index);
         while Index <= Data'Last
           and then Is_In (Character'Val (Data (Index)), DigitSet)
         loop
            Index := Index + 1;
         end loop;
         Skip_Whitespace (Index);
      end Read_Header;

      Index                 : Natural := Data'First;
      PPM_Width, PPM_Height : Natural;
   begin
      Read_Header (Data, Index, PPM_Width, PPM_Height);

      --  Validate buffer dimensions
      if B'Length (1) < PPM_Width or B'Length (2) < PPM_Height then
         raise Constraint_Error
           with
             "Buffer too small: expected at least "
             & PPM_Width'Image
             & "x"
             & PPM_Height'Image
             & ", got "
             & B'Length (1)'Image
             & "x"
             & B'Length (2)'Image;
      end if;

      --  Load pixel data
      for Y in 0 .. PPM_Height - 1 loop
         for X in 0 .. PPM_Width - 1 loop
            B (X, Y) :=
              (R => Data (Index),
               G => Data (Index + 1),
               B => Data (Index + 2), A => 255);
            Index := Index + 3;
         end loop;
      end loop;
   end Read_PPM;


   function Read_PPM (Filename : String) return Buffer is
      File   : File_Type;
      S : Stream_Access;
      Width, Height, Max_Color : Natural;
      Header  : String (1 .. 3);
      R, G, B : Byte;
      C : Character;
   begin
      Open (File, In_File, Filename);
      S := Stream (File);

      -- Read PPM header (P6)
      String'Read (S, Header);
      if Header /= "P6 " and then Header /= "P6" then
         Close(File);
         raise Data_Error with "Not a P6 PPM file";
      end if;

      -- Read width, height, and max color
      Width := Natural'Input (S);
      Height := Natural'Input (S);
      Max_Color := Natural'Input (S);
      if Max_Color > 255 then
         Close (File);
         raise Data_Error with "Max color value > 255 not supported";
      end if;
      if Width < 1 or else Height < 1 then
         Close (File);
         raise Data_Error with "Invalid dimensions";
      end if;

      declare
         Result  : Buffer (1 .. Height, 1 .. Width);
      begin
         -- Skip newline after header
         Character'Read (S, C);

         -- Read pixel data and build Buffer
         for Y in 1 .. Height loop
            for X in 1 .. Width loop
               Byte'Read (S, R);
               Byte'Read (S, G);
               Byte'Read (S, B);
               Result (Y, X) := (R => R, G => G, B => B, A => 255);
            end loop;
         end loop;

         Close (File);
         return Result;
      end;
   exception
      when others =>
         if Is_Open (File) then
            Close (File);
         end if;
         raise;
   end Read_PPM;

end IO;
