with Framebuffer; use Framebuffer;
with Ada.Containers.Vectors;

package Renderer is
   pragma Elaborate_Body;


   type Render_Context (Max_X, Max_Y : Natural) is tagged private;

   type Clip_Rectangle is record
      X_Min, Y_Min : Integer;
      X_Max, Y_Max : Integer;
   end record;

   type Linear_Table_Type is array (Byte) of Float;
   type SRGB_Table_Type is array (Integer range 0 .. 4095) of Byte;

   Linear_From_sRGB : Linear_Table_Type;
   sRGB_From_Linear : SRGB_Table_Type;

   --  Initialization with pixel dimensions (not max indices)
   function Create_Context (Width, Height : Positive) return Render_Context;

   --  Get the width in pixels
   function Get_Width (Context : Render_Context) return Positive;

   --  Get the height in pixels
   function Get_Height (Context : Render_Context) return Positive;

   --  Get the buffer (returns a copy)
   function Get_Buffer (Context : Render_Context) return Buffer;

   --
   --  Clear buffer
   --
   procedure Clear (Context : in out Render_Context; Color: Pixel := Zero_Pixel);

   type Corner_Type is (Top_Left, Top_Right, Bottom_Left, Bottom_Right);

   type Point is record
      X : Natural;
      Y : Natural;
   end record;

   type Point_Array is array (Positive range <>) of Point;

   type Region_Code is (Inside, Left, Right, Bottom, Top);
   type Out_Code is array (Region_Code) of Boolean;

   --
   --  Current_Clip_Rect
   --
   function Current_Clip_Rect (Context : Render_Context) return Clip_Rectangle;

   --
   --  Push Clip rectangle
   --
   procedure Push_Clip_Rect
     (Context : in out Render_Context; X_Min, Y_Min, X_Max, Y_Max : Integer);

   --
   --  Pop the current clipping rectangle
   --
   procedure Pop_Clip_Rect (Context : in out Render_Context);

   --
   --  Put a pixel with clipping
   --
   procedure Put_Pixel
     (Context : in out Render_Context; X, Y : Integer; Color : Pixel);

   --
   --  Get a pixel
   --
   function Get_Pixel (Context : Render_Context; X, Y : Integer) return Pixel;

   --
   --  Draw a line with clipping
   --
   procedure Draw_Line
     (Context        : in out Render_Context;
      X0, Y0, X1, Y1 : Integer;
      Color          : Pixel);

   --
   --  Draw a rectangle with clipping
   --
   procedure Draw_Rectangle
     (Context             : in out Render_Context;
      X, Y, Width, Height : Integer;
      Color               : Pixel);
   --
   --  Draw a filled rectangle with clipping
   --
   procedure Draw_FilledRectangle
     (Context             : in out Render_Context;
      X, Y, Width, Height : Integer;
      Color               : Pixel);

   --
   --  Draw polygon, connects points with lines
   --
   procedure Draw_Polygon
     (Context : in out Render_Context; Points : Point_Array; Color : Pixel);

   --
   --  Draw a filled polygon
   --
   procedure Draw_FilledPolygon
     (Context : in out Render_Context; Points : Point_Array; Color : Pixel);

   --
   --  Draw a triangle
   --
   procedure Draw_Triangle
     (Context : in out Render_Context;
      X1, Y1  : Integer;
      X2, Y2  : Integer;
      X3, Y3  : Integer;
      Color   : Pixel);

   --
   --  Draw filled triangle
   --
   procedure Draw_FilledTriangle
     (Context : in out Render_Context;
      X1, Y1  : Integer;
      X2, Y2  : Integer;
      X3, Y3  : Integer;
      Color   : Pixel);

   --
   --  Draw a circle with clipping
   --
   procedure Draw_Circle
     (Context  : in out Render_Context;
      X_Center : Integer;
      Y_Center : Integer;
      Radius   : Integer;
      Color    : Pixel);

   --
   --  Draw filled circle
   --
   procedure Draw_FilledCircle
     (Context  : in out Render_Context;
      X_Center : Integer;
      Y_Center : Integer;
      Radius   : Integer;
      Color    : Pixel);

   --
   --  Draw an image
   --
   procedure Draw_Image
     (Context        : in out Render_Context;
      Image          : Pixel_Array;
      -- Source image data (passed by reference)
      Dest_X, Dest_Y : Integer    -- Destination coordinates
      );

   --
   --  Draw a rectangle with rouded corners
   --

   procedure Draw_Rounded_Rectangle
     (Context : in out Render_Context;
      X, Y    : Integer;
      --  Top-left corner coordinates (allow negative)
      Width   : Natural;
      --  Width of the rectangle (always positive)
      Height  : Natural;
      --  Height of the rectangle (always positive)
      Radius  : Natural;
      --  Corner radius (always positive)
      Color   : Pixel);

   procedure Draw_Filled_Rounded_Rectangle
     (Context : in out Render_Context;
      X, Y    : Integer;
      --  Top-left corner coordinates
      Width   : Natural;
      --  Width of the rectangle
      Height  : Natural;
      --  Height of the rectangle
      Radius  : Natural;
      --  Corner radius
      Color   : Pixel);

   --
   --  Clip a line from (X0, Y0) to (X1, Y1) to the rectangle defined by
   --  (X_Min, Y_Min) to (X_Max, Y_Max)
   --
   procedure Draw_Clipped_Line
     (B      : in out Buffer;
      X0, Y0 : Integer;
      --  Start point
      X1, Y1 : Integer;
      --  End point
      X_Min  : Integer;
      --  Clip rectangle left
      Y_Min  : Integer;
      --  Clip rectangle bottom
      X_Max  : Integer;
      --  Clip rectangle right
      Y_Max  : Integer;
      --  Clip rectangle top
      Color  : Pixel);

private

   package Clip_Stack_Package is new
     Ada.Containers.Vectors
       (Index_Type   => Natural,
        Element_Type => Clip_Rectangle);

   type Clip_Edge is (Left, Right, Bottom, Top);

   -- Low-level clipping procedure
   procedure Clip_Against_Edge
     (Input_Points  : Point_Array;
      Input_Count   : Natural;
      Edge          : Clip_Edge;
      Clip_Rect     : Clip_Rectangle;
      Output_Points : out Point_Array;
      Output_Count  : out Natural);

   -- Helper procedure for clipping polygons
   procedure Clip_Polygon
     (Context       : in out Render_Context;
      Input_Points  : Point_Array;
      Input_Count   : Natural;
      Output_Points : out Point_Array;
      Output_Count  : out Natural);

   --  Buffer indices go from 0 to Max_X and 0 to Max_Y
   type Render_Context (Max_X, Max_Y : Natural) is tagged record
      The_Buffer : Buffer (0 .. Max_X, 0 .. Max_Y);
      Clip_Stack : Clip_Stack_Package.Vector;
   end record;

end Renderer;
