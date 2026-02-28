pragma Ada_2022;
pragma Extensions_Allowed (All_Extensions);

with Ada.Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Containers;

package body Renderer is

   procedure Log (Item : String) renames Ada.Text_IO.Put_Line;

   --
   --  Create a new render context with a new buffer of the specified pixel dimensions
   --
   function Create_Context (Width, Height : Positive) return Render_Context is
      --  Calculate max indices from pixel dimensions
      Context : Render_Context (Width - 1, Height - 1);
   begin
      --  Set the default clipping region to the entire buffer
      Context.Clip_Stack.Append (Clip_Rectangle'(0, 0, Width - 1, Height - 1));
      return Context;
   end Create_Context;

   --  Get the width in pixels
   function Get_Width (Context : Render_Context) return Positive is
   begin
      return Context.Max_X + 1;
   end Get_Width;

   --  Get the height in pixels
   function Get_Height (Context : Render_Context) return Positive is
   begin
      return Context.Max_Y + 1;
   end Get_Height;

   --  Get the buffer (returns a copy)
   function Get_Buffer (Context : Render_Context) return Buffer is
   begin
      return Context.The_Buffer;
   end Get_Buffer;

   --
   --  Clear buffer
   --
   procedure Clear (Context : in out Render_Context; Color : Pixel := Zero_Pixel) is
   begin
      Context.The_Buffer.Clear (Color);
   end Clear;

   --
   --  Push Clip rectangle
   --
   procedure Push_Clip_Rect
     (Context : in out Render_Context; X_Min, Y_Min, X_Max, Y_Max : Integer)
   is
      Current : Clip_Rectangle;
   begin
      if Context.Clip_Stack.Is_Empty then
         --  No current clip region, use the new one as-is with type qualification
         Current := (X_Min, Y_Min, X_Max, Y_Max);
      else
         --  Intersect with the current clip region
         declare
            Top : Clip_Rectangle := Context.Clip_Stack.Last_Element;
         begin
            Current.X_Min := Integer'Max (Top.X_Min, X_Min);
            Current.Y_Min := Integer'Max (Top.Y_Min, Y_Min);
            Current.X_Max := Integer'Min (Top.X_Max, X_Max);
            Current.Y_Max := Integer'Min (Top.Y_Max, Y_Max);
         end;
      end if;

      --  Ensure the region is valid and append with type qualification
      if Current.X_Min <= Current.X_Max and then Current.Y_Min <= Current.Y_Max
      then
         Context.Clip_Stack.Append
           (Clip_Rectangle'
              (Current.X_Min, Current.Y_Min, Current.X_Max, Current.Y_Max));
      end if;
   end Push_Clip_Rect;

   --
   --  Pop the current clipping rectangle
   --
   procedure Pop_Clip_Rect (Context : in out Render_Context) is
   begin
      if not Context.Clip_Stack.Is_Empty then
         Context.Clip_Stack.Delete_Last;
      end if;
   end Pop_Clip_Rect;

   --
   --  Get the current clipping rectangle
   --
   function Current_Clip_Rect (Context : Render_Context) return Clip_Rectangle
   is
   begin
      if Context.Clip_Stack.Is_Empty then
         return (0, 0, Context.Max_X, Context.Max_Y);
      else
         return Context.Clip_Stack.Last_Element;
      end if;
   end Current_Clip_Rect;

   procedure Clip_Against_Edge
     (Input_Points  : Point_Array;
      Input_Count   : Natural;
      Edge          : Clip_Edge;
      Clip_Rect     : Clip_Rectangle;
      Output_Points : out Point_Array;
      Output_Count  : out Natural)
   is
      P, Q               : Point;
      Intersection       : Point;
      Inside_P, Inside_Q : Boolean;
   begin
      Output_Count := 0;
      for I in 1 .. Input_Count loop
         P := Input_Points (I);
         Q := Input_Points ((I mod Input_Count) + 1);

         case Edge is
            when Left   =>
               Inside_P := P.X >= Clip_Rect.X_Min;
               Inside_Q := Q.X >= Clip_Rect.X_Min;

               if Inside_P then
                  if Inside_Q then
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Q;
                  else
                     if P.X /= Q.X then
                        Intersection.Y :=
                          P.Y
                          + (Q.Y - P.Y)
                            * (Clip_Rect.X_Min - P.X)
                            / (Q.X - P.X);
                     else
                        Intersection.Y := P.Y;
                     end if;
                     Intersection.X := Clip_Rect.X_Min;
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Intersection;
                  end if;
               elsif Inside_Q then
                  if P.X /= Q.X then
                     Intersection.Y :=
                       P.Y
                       + (Q.Y - P.Y) * (Clip_Rect.X_Min - P.X) / (Q.X - P.X);
                  else
                     Intersection.Y := P.Y;
                  end if;
                  Intersection.X := Clip_Rect.X_Min;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Intersection;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Q;
               end if;

            when Right  =>
               Inside_P := P.X <= Clip_Rect.X_Max;
               Inside_Q := Q.X <= Clip_Rect.X_Max;

               if Inside_P then
                  if Inside_Q then
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Q;
                  else
                     if P.X /= Q.X then
                        Intersection.Y :=
                          P.Y
                          + (Q.Y - P.Y)
                            * (Clip_Rect.X_Max - P.X)
                            / (Q.X - P.X);
                     else
                        Intersection.Y := P.Y;
                     end if;
                     Intersection.X := Clip_Rect.X_Max;
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Intersection;
                  end if;
               elsif Inside_Q then
                  if P.X /= Q.X then
                     Intersection.Y :=
                       P.Y
                       + (Q.Y - P.Y) * (Clip_Rect.X_Max - P.X) / (Q.X - P.X);
                  else
                     Intersection.Y := P.Y;
                  end if;
                  Intersection.X := Clip_Rect.X_Max;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Intersection;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Q;
               end if;

            when Bottom =>
               Inside_P := P.Y >= Clip_Rect.Y_Min;
               Inside_Q := Q.Y >= Clip_Rect.Y_Min;

               if Inside_P then
                  if Inside_Q then
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Q;
                  else
                     if P.Y /= Q.Y then
                        Intersection.X :=
                          P.X
                          + (Q.X - P.X)
                            * (Clip_Rect.Y_Min - P.Y)
                            / (Q.Y - P.Y);
                     else
                        Intersection.X := P.X;
                     end if;
                     Intersection.Y := Clip_Rect.Y_Min;
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Intersection;
                  end if;
               elsif Inside_Q then
                  if P.Y /= Q.Y then
                     Intersection.X :=
                       P.X
                       + (Q.X - P.X) * (Clip_Rect.Y_Min - P.Y) / (Q.Y - P.Y);
                  else
                     Intersection.X := P.X;
                  end if;
                  Intersection.Y := Clip_Rect.Y_Min;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Intersection;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Q;
               end if;

            when Top    =>
               Inside_P := P.Y <= Clip_Rect.Y_Max;
               Inside_Q := Q.Y <= Clip_Rect.Y_Max;

               if Inside_P then
                  if Inside_Q then
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Q;
                  else
                     if P.Y /= Q.Y then
                        Intersection.X :=
                          P.X
                          + (Q.X - P.X)
                            * (Clip_Rect.Y_Max - P.Y)
                            / (Q.Y - P.Y);
                     else
                        Intersection.X := P.X;
                     end if;
                     Intersection.Y := Clip_Rect.Y_Max;
                     Output_Count := Output_Count + 1;
                     Output_Points (Output_Count) := Intersection;
                  end if;
               elsif Inside_Q then
                  if P.Y /= Q.Y then
                     Intersection.X :=
                       P.X
                       + (Q.X - P.X) * (Clip_Rect.Y_Max - P.Y) / (Q.Y - P.Y);
                  else
                     Intersection.X := P.X;
                  end if;
                  Intersection.Y := Clip_Rect.Y_Max;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Intersection;
                  Output_Count := Output_Count + 1;
                  Output_Points (Output_Count) := Q;
               end if;
         end case;
      end loop;
   end Clip_Against_Edge;

   --  Clip a polygon against all edges of the clipping rectangle
   procedure Clip_Polygon
     (Context       : in out Render_Context;
      Input_Points  : Point_Array;
      Input_Count   : Natural;
      Output_Points : out Point_Array;
      Output_Count  : out Natural)
   is
      Temp_Points : Point_Array (1 .. 8);  --  Max 8 points after clipping
      Temp_Count  : Natural;
      Clip_Rect   : constant Clip_Rectangle := Current_Clip_Rect (Context);
   begin
      --  Make a copy of the input points
      Temp_Points (1 .. Input_Count) := Input_Points (1 .. Input_Count);
      Temp_Count := Input_Count;

      --  Clip against each edge
      Clip_Against_Edge
        (Temp_Points,
         Temp_Count,
         Left,
         Clip_Rect,
         Output_Points,
         Output_Count);
      if Output_Count = 0 then
         return;
      end if;
      Temp_Points (1 .. Output_Count) := Output_Points (1 .. Output_Count);
      Temp_Count := Output_Count;

      Clip_Against_Edge
        (Temp_Points,
         Temp_Count,
         Right,
         Clip_Rect,
         Output_Points,
         Output_Count);
      if Output_Count = 0 then
         return;
      end if;
      Temp_Points (1 .. Output_Count) := Output_Points (1 .. Output_Count);
      Temp_Count := Output_Count;

      Clip_Against_Edge
        (Temp_Points,
         Temp_Count,
         Bottom,
         Clip_Rect,
         Output_Points,
         Output_Count);
      if Output_Count = 0 then
         return;
      end if;
      Temp_Points (1 .. Output_Count) := Output_Points (1 .. Output_Count);
      Temp_Count := Output_Count;

      Clip_Against_Edge
        (Temp_Points, Temp_Count, Top, Clip_Rect, Output_Points, Output_Count);
   end Clip_Polygon;

   --
   --  Gets the color of a pixel from the render context.
   --  Returns a default color if out of bounds (for safety).
   --
   function Get_Pixel (Context : Render_Context; X, Y : Integer) return Pixel is
      Default_Color : constant Pixel := (0, 0, 0, 255);
   begin
      return Default_Color when X < 0 or else Y < 0 or else X >= Context.Max_X or else Y >= Context.Max_Y;
      return Context.The_Buffer (X, Y);
   end Get_Pixel;

   --
   --  Put a pixel with clipping
   --
   procedure Put_Pixel
     (Context : in out Render_Context; X, Y : Integer; Color : Pixel)
   is
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);
   begin
      if X >= Clip.X_Min
        and then X <= Clip.X_Max
        and then Y >= Clip.Y_Min
        and then Y <= Clip.Y_Max
      then
         Context.The_Buffer (X, Y) := Color;
      end if;
   end Put_Pixel;

   --
   --  Draw a line with clipping
   --
   procedure Draw_Line
     (Context : in out Render_Context; X0, Y0, X1, Y1 : Integer; Color : Pixel)
   is
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);
   begin
      Draw_Clipped_Line
        (Context.The_Buffer,
         X0,
         Y0,
         X1,
         Y1,
         Clip.X_Min,
         Clip.Y_Min,
         Clip.X_Max,
         Clip.Y_Max,
         Color);
   end Draw_Line;

   --
   --  Draw a rectangle with clipping
   --
   procedure Draw_Rectangle
     (Context             : in out Render_Context;
      X, Y, Width, Height : Integer;
      Color               : Pixel)
   is
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);
      X1   : constant Integer := Integer'Max (X, Clip.X_Min);
      Y1   : constant Integer := Integer'Max (Y, Clip.Y_Min);
      X2   : constant Integer := Integer'Min (X + Width - 1, Clip.X_Max);
      Y2   : constant Integer := Integer'Min (Y + Height - 1, Clip.Y_Max);
   begin
      --  Check if rectangle is visible at all
      if X1 <= X2 and then Y1 <= Y2 then
         --  Draw top and bottom edges
         for I in X1 .. X2 loop
            Context.The_Buffer (I, Y1) := Color;
            Context.The_Buffer (I, Y2) := Color;
         end loop;

         --  Draw left and right edges
         for J in Y1 .. Y2 loop
            Context.The_Buffer (X1, J) := Color;
            Context.The_Buffer (X2, J) := Color;
         end loop;
      end if;
   end Draw_Rectangle;

   --
   --  Draw a filled rectangle with clipping
   --
   procedure Draw_FilledRectangle
     (Context             : in out Render_Context;
      X, Y, Width, Height : Integer;
      Color               : Pixel)
   is
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);
      X1   : constant Integer := Integer'Max (X, Clip.X_Min);
      Y1   : constant Integer := Integer'Max (Y, Clip.Y_Min);
      X2   : constant Integer := Integer'Min (X + Width - 1, Clip.X_Max);
      Y2   : constant Integer := Integer'Min (Y + Height - 1, Clip.Y_Max);
   begin
      if X1 <= X2 and then Y1 <= Y2 then
         for I in X1 .. X2 loop
            for J in Y1 .. Y2 loop
               Context.The_Buffer (I, J) := Color;
            end loop;
         end loop;
      end if;
   end Draw_FilledRectangle;

   --
   --  Set a pixel in the framebuffer
   --
   procedure Put_Pixel (B : in out Buffer; X, Y : Natural; Color : Pixel) is
   begin
      if X in B'Range (1) and then Y in B'Range (2) then
         B (X, Y) := Color;
      end if;
   end Put_Pixel;

   --
   --  Draw a line
   --
   procedure Draw_Line
     (B : in out Buffer; X0, Y0, X1, Y1 : Natural; Color : Pixel)
   is
      --  Convert to integers for arithmetic
      X_Start : constant Integer := Integer (X0);
      Y_Start : constant Integer := Integer (Y0);
      X_End   : constant Integer := Integer (X1);
      Y_End   : constant Integer := Integer (Y1);

      --  Step directions
      SX : constant Integer := (if X_Start < X_End then 1 else -1);
      SY : constant Integer := (if Y_Start < Y_End then 1 else -1);

      --  Current position
      X : Integer := X_Start;
      Y : Integer := Y_Start;
   begin
      --  Vertical line (X_Start = X_End)
      if X_Start = X_End then
         while Y /= Y_End loop
            Put_Pixel (B, X, Y, Color);
            Y := Y + SY;
         end loop;
         Put_Pixel (B, X, Y, Color);
         return;
      end if;

      --  Horizontal line (Y_Start = Y_End)
      if Y_Start = Y_End then
         while X /= X_End loop
            Put_Pixel (B, X, Y, Color);
            X := X + SX;
         end loop;
         Put_Pixel (B, X, Y, Color);
         return;
      end if;

      --  Diagonal line (Bresenham's algorithm)
      declare
         DX  : constant Integer := abs (X_End - X_Start);
         DY  : constant Integer := abs (Y_End - Y_Start);
         Err : Integer;
      begin
         if DX > DY then
            --  Shallow slope
            Err := DX / 2;
            while X /= X_End loop
               Put_Pixel (B, X, Y, Color);
               X := X + SX;
               Err := Err - DY;
               if Err < 0 then
                  Y := Y + SY;
                  Err := Err + DX;
               end if;
            end loop;
         else
            --  Steep slope
            Err := DY / 2;
            while Y /= Y_End loop
               Put_Pixel (B, X, Y, Color);
               Y := Y + SY;
               Err := Err - DX;
               if Err < 0 then
                  X := X + SX;
                  Err := Err + DY;
               end if;
            end loop;
         end if;
         Put_Pixel (B, X, Y, Color);
      end;
   end Draw_Line;

   --
   --  Draw polygon with clipping, connects points with lines
   --
   procedure Draw_Polygon (
      Context    : in out Render_Context;
      Points     : Point_Array;
      Color      : Pixel)
   is
      --  Quick exit if we don't have enough points
      N : constant Natural := Points'Length;
   begin
      if N < 2 then
         return;
      end if;

      --  Draw lines between consecutive points
      for I in 1 .. N - 1 loop
         Draw_Line (
            Context,
            Points (I).X,
            Points (I).Y,
            Points (I + 1).X,
            Points (I + 1).Y,
            Color);
      end loop;

      --  Close the polygon by drawing a line from last point to first point
      Draw_Line (
         Context,
         Points (N).X,
         Points (N).Y,
         Points (1).X,
         Points (1).Y,
         Color);
   end Draw_Polygon;

   --
   --  Draw a filled polygon
   --
   procedure Draw_FilledPolygon (
      Context    : in out Render_Context;
      Points     : Point_Array;
      Color      : Pixel)
   is
      --  Get clip rectangle once
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);

      --  Initialize bounding box with clip rectangle bounds
      Min_X : Integer := Clip.X_Max;  --  Start with max value
      Max_X : Integer := Clip.X_Min;  --  Start with min value
      Min_Y : Integer := Clip.Y_Max;
      Max_Y : Integer := Clip.Y_Min;

      --  Cache the polygon length and calculate rough bounds for quick rejection
      N : constant Natural := Points'Length;
      Polygon_Min_X : Integer := Integer'Last;
      Polygon_Max_X : Integer := Integer'First;
      Polygon_Min_Y : Integer := Integer'Last;
      Polygon_Max_Y : Integer := Integer'First;

      --  Function to check if a point is inside the polygon
      function Point_In_Polygon (X, Y : Integer) return Boolean is
         Inside : Boolean := False;
      begin
         for I in 1 .. N loop
            declare
               P1 : Point renames Points (I);
               P2 : Point renames Points ((if I = N then 1 else I + 1));
               Intersection_X : Float;
               Y1_Above : constant Boolean := P1.Y > Y;
               Y2_Above : constant Boolean := P2.Y > Y;
            begin
               --  Quick check if edge might intersect our scanline
               if Y1_Above /= Y2_Above then
                  if P2.Y = P1.Y then
                     --  Horizontal edge - count as intersection if point is on the edge
                     if Y = P1.Y and then X <= Integer'Max (P1.X, P2.X) and then X >= Integer'Min (P1.X, P2.X) then
                        return True;
                     end if;
                  else
                     --  Calculate intersection X coordinate
                     Intersection_X := Float (P1.X) + Float (Y - P1.Y) *
                                    Float (P2.X - P1.X) / Float (P2.Y - P1.Y);

                     --  Check if our test point is left of the intersection
                     if X < Integer (Float'Truncation (Intersection_X)) then
                        Inside := not Inside;
                     end if;
                  end if;
               end if;
            end;
         end loop;
         return Inside;
      end Point_In_Polygon;

   begin
      --  Calculate bounding box and polygon bounds simultaneously
      for I in Points'Range loop
         if Points (I).X < Min_X then
            Min_X := Points (I).X;
         end if;
         if Points (I).X > Max_X then
            Max_X := Points (I).X;
         end if;
         if Points (I).Y < Min_Y then
            Min_Y := Points (I).Y;
         end if;
         if Points (I).Y > Max_Y then
            Max_Y := Points (I).Y;
         end if;

         --  Calculate polygon bounds for quick rejection
         if Points (I).X < Polygon_Min_X then
            Polygon_Min_X := Points (I).X;
         end if;
         if Points (I).X > Polygon_Max_X then
            Polygon_Max_X := Points (I).X;
         end if;
         if Points (I).Y < Polygon_Min_Y then
            Polygon_Min_Y := Points (I).Y;
         end if;
         if Points (I).Y > Polygon_Max_Y then
            Polygon_Max_Y := Points (I).Y;
         end if;
      end loop;

      --  Apply clipping to bounding box
      Min_X := Integer'Max (Min_X, Clip.X_Min);
      Max_X := Integer'Min (Max_X, Clip.X_Max);
      Min_Y := Integer'Max (Min_Y, Clip.Y_Min);
      Max_Y := Integer'Min (Max_Y, Clip.Y_Max);

      --  Early exit if bounding box is empty
      if Min_X > Max_X or else Min_Y > Max_Y then
         return;
      end if;

      --  For each pixel in the bounding box, check if it's inside the polygon
      --  Skip rows outside the polygon's vertical bounds
      for Y in Min_Y .. Max_Y loop
         --  Quick check if this row might contain polygon pixels
         if Y >= Polygon_Min_Y and then Y <= Polygon_Max_Y then
            --  Skip columns outside the polygon's horizontal bounds
            for X in Min_X .. Max_X loop
               if X >= Polygon_Min_X and then X <= Polygon_Max_X then
                  if Point_In_Polygon (X, Y) then
                     Put_Pixel (Context, X, Y, Color);
                  end if;
               end if;
            end loop;
         end if;
      end loop;
   end Draw_FilledPolygon;

   --
   --  Draw a triangle with clipping
   --
   procedure Draw_Triangle
     (Context : in out Render_Context;
      X1, Y1  : Integer;
      X2, Y2  : Integer;
      X3, Y3  : Integer;
      Color   : Pixel)
   is
      --  Create an array of points for the triangle
      Input_Points : Point_Array (1 .. 3) := [(X1, Y1), (X2, Y2), (X3, Y3)];

      --  Use a local array with enough space for the clipped polygon
      --  A triangle can become a quadrilateral or pentagon after clipping
      Output_Points : Point_Array (1 .. 5);
      Output_Count  : Natural;
   begin
      --  Clip the triangle against the current clip rectangle
      Clip_Polygon (Context, Input_Points, 3, Output_Points, Output_Count);

      --  If we have at least 2 points after clipping, draw the resulting polygon
      if Output_Count >= 2 then
         --  Draw lines between each pair of consecutive points
         for I in 1 .. Output_Count - 1 loop
            Draw_Line
              (Context,
               Output_Points (I).X,
               Output_Points (I).Y,
               Output_Points (I + 1).X,
               Output_Points (I + 1).Y,
               Color);
         end loop;

         --  Close the polygon by connecting the last point to the first point
         if Output_Count > 2 then
            Draw_Line
              (Context,
               Output_Points (Output_Count).X,
               Output_Points (Output_Count).Y,
               Output_Points (1).X,
               Output_Points (1).Y,
               Color);
         end if;
      end if;
   end Draw_Triangle;

   --
   --  Draw filled triangle
   --
   procedure Draw_FilledTriangle (
      Context    : in out Render_Context;
      X1, Y1     : Integer;
      X2, Y2     : Integer;
      X3, Y3     : Integer;
      Color      : Pixel)
   is
      --  Define a point type
      type Point is record
         X, Y : Integer;
      end record;

      --  Sort vertices by Y coordinate
      procedure Sort_Vertices (V1, V2, V3 : in out Point) is
         Temp : Point;
      begin
         if V1.Y > V2.Y then
            Temp := V1;
            V1 := V2;
            V2 := Temp;
         end if;
         if V1.Y > V3.Y then
            Temp := V1;
            V1 := V3;
            V3 := Temp;
         end if;
         if V2.Y > V3.Y then
            Temp := V2;
            V2 := V3;
            V3 := Temp;
         end if;
      end Sort_Vertices;

      --  Calculate the intersection of a line with a horizontal scanline
      function Calculate_X (Line_Start, Line_End : Point; Y : Integer) return Float is
      begin
         if Line_Start.Y = Line_End.Y then
            return Float (Line_Start.X);  -- Horizontal line
         end if;

         return Float (Line_Start.X) +
               Float (Y - Line_Start.Y) *
               Float (Line_End.X - Line_Start.X) /
               Float (Line_End.Y - Line_Start.Y);
      end Calculate_X;

      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);
      V1, V2, V3 : Point;
      X_Left, X_Right : Integer;
      Y : Integer;
      Edge1_X, Edge2_X : Float;
   begin
      --  Initialize vertices
      V1 := (X => X1, Y => Y1);
      V2 := (X => X2, Y => Y2);
      V3 := (X => X3, Y => Y3);

      --  Quick rejection: if triangle is completely outside clip rectangle, return
      if (X1 < Clip.X_Min and then X2 < Clip.X_Min and then X3 < Clip.X_Min) or else
         (X1 > Clip.X_Max and then X2 > Clip.X_Max and then X3 > Clip.X_Max) or else
         (Y1 < Clip.Y_Min and then Y2 < Clip.Y_Min and then Y3 < Clip.Y_Min) or else
         (Y1 > Clip.Y_Max and then Y2 > Clip.Y_Max and then Y3 > Clip.Y_Max)
      then
         return;
      end if;

      --  Sort vertices by Y coordinate
      Sort_Vertices (V1, V2, V3);

      --  Calculate bounding box
      declare
         Min_Y : constant Integer := Integer'Max (V1.Y, Clip.Y_Min);
         Max_Y : constant Integer := Integer'Min (V3.Y, Clip.Y_Max);
      begin
         --  Draw the triangle using scanline approach
         for Y in Min_Y .. Max_Y loop
            --  Calculate X positions on the edges
            if Y < V2.Y or else V2.Y = V3.Y then
               --  Top part of the triangle or flat bottom
               Edge1_X := Calculate_X (V1, V3, Y);
               Edge2_X := Calculate_X (V1, V2, Y);
            else
               --  Bottom part of the triangle
               Edge1_X := Calculate_X (V1, V3, Y);
               Edge2_X := Calculate_X (V2, V3, Y);
            end if;

            --  Determine left and right edges
            if Edge1_X < Edge2_X then
               X_Left := Integer (Edge1_X);
               X_Right := Integer (Edge2_X);
            else
               X_Left := Integer (Edge2_X);
               X_Right := Integer (Edge1_X);
            end if;

            --  Clip to the horizontal bounds
            X_Left := Integer'Max (X_Left, Clip.X_Min);
            X_Right := Integer'Min (X_Right, Clip.X_Max);

            --  Draw the scanline
            if X_Left <= X_Right then
               for X in X_Left .. X_Right loop
                  Put_Pixel (Context, X, Y, Color);
               end loop;
            end if;
         end loop;
      end;
   end Draw_FilledTriangle;

   --
   --  Draw a circle with clipping
   --
   procedure Draw_Circle (
      Context    : in out Render_Context;
      X_Center   : Integer;
      Y_Center   : Integer;
      Radius     : Integer;
      Color      : Pixel)
   is
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);

      --  Quick rejection: if circle is completely outside clip rectangle, return
   begin
      if (X_Center + Radius < Clip.X_Min) or else
         (X_Center - Radius > Clip.X_Max) or else
         (Y_Center + Radius < Clip.Y_Min) or else
         (Y_Center - Radius > Clip.Y_Max)
      then
         return;
      end if;

      --  Use standard midpoint circle algorithm
      declare
         X : Integer := 0;
         Y : Integer := Radius;
         D : Integer := 3 - 2 * Radius;
      begin
         while X <= Y loop
            --  Draw only the 8 symmetric points on the circumference
            if X_Center + X >= Clip.X_Min and then X_Center + X <= Clip.X_Max then
               if Y_Center + Y >= Clip.Y_Min and then Y_Center + Y <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center + X, Y_Center + Y, Color);
               end if;
               if Y_Center - Y >= Clip.Y_Min and then Y_Center - Y <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center + X, Y_Center - Y, Color);
               end if;
            end if;

            if X_Center - X >= Clip.X_Min and then X_Center - X <= Clip.X_Max then
               if Y_Center + Y >= Clip.Y_Min and then Y_Center + Y <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center - X, Y_Center + Y, Color);
               end if;
               if Y_Center - Y >= Clip.Y_Min and then Y_Center - Y <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center - X, Y_Center - Y, Color);
               end if;
            end if;

            if X_Center + Y >= Clip.X_Min and then X_Center + Y <= Clip.X_Max then
               if Y_Center + X >= Clip.Y_Min and then Y_Center + X <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center + Y, Y_Center + X, Color);
               end if;
               if Y_Center - X >= Clip.Y_Min and then Y_Center - X <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center + Y, Y_Center - X, Color);
               end if;
            end if;

            if X_Center - Y >= Clip.X_Min and then X_Center - Y <= Clip.X_Max then
               if Y_Center + X >= Clip.Y_Min and then Y_Center + X <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center - Y, Y_Center + X, Color);
               end if;
               if Y_Center - X >= Clip.Y_Min and then Y_Center - X <= Clip.Y_Max then
                  Put_Pixel (Context, X_Center - Y, Y_Center - X, Color);
               end if;
            end if;

            --  Update for next iteration
            if D < 0 then
               D := D + 4 * X + 6;
            else
               D := D + 4 * (X - Y) + 10;
               Y := Y - 1;
            end if;
            X := X + 1;
         end loop;
      end;
   end Draw_Circle;

   --
   --  Draw filled circle with clipping
   --
   procedure Draw_FilledCircle (
      Context    : in out Render_Context;
      X_Center   : Integer;
      Y_Center   : Integer;
      Radius     : Integer;
      Color      : Pixel)
   is
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);

      --  Quick rejection: if circle is completely outside clip rectangle, return
   begin
      if (X_Center + Radius < Clip.X_Min) or else
         (X_Center - Radius > Clip.X_Max) or else
         (Y_Center + Radius < Clip.Y_Min) or else
         (Y_Center - Radius > Clip.Y_Max)
      then
         return;
      end if;

      --  If circle is completely inside clip rectangle, use standard filled circle algorithm
      if (X_Center - Radius >= Clip.X_Min) and then
         (X_Center + Radius <= Clip.X_Max) and then
         (Y_Center - Radius >= Clip.Y_Min) and then
         (Y_Center + Radius <= Clip.Y_Max)
      then
         --  Use standard midpoint circle algorithm with horizontal line filling
         declare
            X : Integer := 0;
            Y : Integer := Radius;
            D : Integer := 3 - 2 * Radius;
         begin
            while X <= Y loop
               --  Draw horizontal lines for each Y level
               for DX in -X .. X loop
                  Put_Pixel (Context, X_Center + DX, Y_Center + Y, Color);
                  if Y /= 0 then  -- Avoid double-drawing the center line
                     Put_Pixel (Context, X_Center + DX, Y_Center - Y, Color);
                  end if;
               end loop;

               if X /= Y then  --  Avoid double-drawing when X = Y
                  for DX in -Y .. Y loop
                     Put_Pixel (Context, X_Center + DX, Y_Center + X, Color);
                     Put_Pixel (Context, X_Center + DX, Y_Center - X, Color);
                  end loop;
               end if;

               if D < 0 then
                  D := D + 4 * X + 6;
               else
                  D := D + 4 * (X - Y) + 10;
                  Y := Y - 1;
               end if;
               X := X + 1;
            end loop;
         end;
         return;
      end if;

      --  Circle intersects with clip rectangle - use scanline approach with clipping
      declare
         --  Calculate the bounding box of the circle
         X_Min : constant Integer := Integer'Max (X_Center - Radius, Clip.X_Min);
         X_Max : constant Integer := Integer'Min (X_Center + Radius, Clip.X_Max);
         Y_Min : constant Integer := Integer'Max (Y_Center - Radius, Clip.Y_Min);
         Y_Max : constant Integer := Integer'Min (Y_Center + Radius, Clip.Y_Max);

         --  For each scanline, calculate the intersection points with the circle
         Y : Integer;
         DY : Integer;
         Distance_Squared : Integer;
         X_Start, X_End : Integer;
      begin
         for Y in Y_Min .. Y_Max loop
            DY := Y - Y_Center;
            Distance_Squared := Radius * Radius - DY * DY;

            if Distance_Squared >= 0 then
               X_Start := X_Center - Integer (Sqrt (Float (Distance_Squared)));
               X_End := X_Center + Integer (Sqrt (Float (Distance_Squared)));

               --  Clip the X range to the clip rectangle
               X_Start := Integer'Max (X_Start, Clip.X_Min);
               X_End := Integer'Min (X_End, Clip.X_Max);

               --  Draw the horizontal line segment
               if X_Start <= X_End then
                  for X in X_Start .. X_End loop
                     Put_Pixel (Context, X, Y, Color);
                  end loop;
               end if;
            end if;
         end loop;
      end;

   end Draw_FilledCircle;

   --
   --  Draw an image with clipping
   --
   procedure Draw_Image (
      Context      : in out Render_Context;
      Image        : Pixel_Array;  --  Source image (read-only)
      Dest_X, Dest_Y : Integer)    --  Destination coordinates
   is
      --  Get current clip rectangle
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);

      --  Calculate image dimensions and destination boundaries
      Image_Width  : constant Natural := Image'Last (1) - Image'First (1) + 1;
      Image_Height : constant Natural := Image'Last (2) - Image'First (2) + 1;
      Dest_Right   : constant Integer := Dest_X + Integer (Image_Width) - 1;
      Dest_Bottom  : constant Integer := Dest_Y + Integer (Image_Height) - 1;

      --  Clip destination coordinates to clip rectangle
      Dest_Left   : constant Integer := Integer'Max (Dest_X, Clip.X_Min);
      Dest_Top    : constant Integer := Integer'Max (Dest_Y, Clip.Y_Min);
      Dest_Right_Clipped  : constant Integer := Integer'Min (Dest_Right, Clip.X_Max);
      Dest_Bottom_Clipped : constant Integer := Integer'Min (Dest_Bottom, Clip.Y_Max);

      --  Calculate final dimensions after clipping
      Final_Width  : constant Natural := Natural'Max (0, Dest_Right_Clipped - Dest_Left + 1);
      Final_Height : constant Natural := Natural'Max (0, Dest_Bottom_Clipped - Dest_Top + 1);
   begin
      --  Quick rejection tests
      if Final_Width = 0 or else Final_Height = 0 then
         return;  --  Nothing to draw
      end if;

      if Dest_Left > Clip.X_Max or else Dest_Top > Clip.Y_Max then
         return;  --  Destination completely outside clip rectangle
      end if;

      --  Draw the complete image with clipping
      for Y in 0 .. Final_Height - 1 loop
         for X in 0 .. Final_Width - 1 loop
            --  Safe type conversion from Pixel_Array to Buffer
            Context.The_Buffer (Dest_Left + X, Dest_Top + Y) :=
            Buffer (Image)(Image'First (1) + (Dest_Left - Dest_X) + X,
                           Image'First (2) + (Dest_Top - Dest_Y) + Y);
         end loop;
      end loop;
   end Draw_Image;

   --------------------------------------------------------------------------------
   --  Draw_Rounded_Rectangle
   --
   --  DESCRIPTION:
   --    Draws a rounded rectangle with the specified dimensions and corner radius.
   --    Fully respects the clip rectangle for all drawing operations.
   --
   --  PARAMETERS:
   --    Context    --  Render context containing the drawing buffer
   --    X, Y       --  Top-left corner coordinates
   --    Width      --  Width of the rectangle
   --    Height     --  Height of the rectangle
   --    Radius     --  Radius of the rounded corners
   --    Color      --  Color to use for drawing the rectangle
   --------------------------------------------------------------------------------
   procedure Draw_Rounded_Rectangle (
      Context    : in out Render_Context;
      X, Y       : Integer;           --  Top-left corner coordinates
      Width      : Natural;           --  Width of the rectangle
      Height     : Natural;           --  Height of the rectangle
      Radius     : Natural;           --  Corner radius
      Color      : Pixel)
   is
      --  Get clip rectangle
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);

      --  Calculate bounds
      X2 : constant Integer := X + Integer (Width) - 1;
      Y2 : constant Integer := Y + Integer (Height) - 1;

      --  Draw a quarter circle (corner) with clipping
      procedure Draw_Quarter_Circle (Center_X, Center_Y : Integer; Corner : Corner_Type) is
         X_Rad : Integer := 0;
         Y_Rad : Integer := Integer'Min (Integer (Radius), Integer'Min (Integer (Width), Integer (Height)) / 2);
         D     : Integer := 1 - 2 * Y_Rad;
         Error : Integer;
      begin
         while X_Rad <= Y_Rad loop
            case Corner is
               when Top_Right =>
                  Put_Pixel (Context, Center_X + X_Rad, Center_Y - Y_Rad, Color);
                  Put_Pixel (Context, Center_X + Y_Rad, Center_Y - X_Rad, Color);
               when Bottom_Right =>
                  Put_Pixel (Context, Center_X + X_Rad, Center_Y + Y_Rad, Color);
                  Put_Pixel (Context, Center_X + Y_Rad, Center_Y + X_Rad, Color);
               when Bottom_Left =>
                  Put_Pixel (Context, Center_X - X_Rad, Center_Y + Y_Rad, Color);
                  Put_Pixel (Context, Center_X - Y_Rad, Center_Y + X_Rad, Color);
               when Top_Left =>
                  Put_Pixel (Context, Center_X - X_Rad, Center_Y - Y_Rad, Color);
                  Put_Pixel (Context, Center_X - Y_Rad, Center_Y - X_Rad, Color);
            end case;

            Error := 2 * (D + Y_Rad) - 1;
            if D < 0 and then Error <= 0 then
               D := D + 2 * X_Rad + 1;
               X_Rad := X_Rad + 1;
            elsif D > 0 and then Error > 0 then
               D := D - 2 * Y_Rad + 1;
               Y_Rad := Y_Rad - 1;
            else
               D := D + 2 * (X_Rad - Y_Rad);
               X_Rad := X_Rad + 1;
               Y_Rad := Y_Rad - 1;
            end if;
         end loop;
      end Draw_Quarter_Circle;

   begin
      --  Quick exit if completely outside clip rectangle
      if X2 < Clip.X_Min or else X > Clip.X_Max or else Y2 < Clip.Y_Min or else Y > Clip.Y_Max then
         return;
      end if;

      --  Calculate effective radius and corner points
      declare
         Effective_Radius : constant Integer := Integer'Min (Integer (Radius), Integer'Min (Integer (Width), Integer (Height)) / 2);
         Left   : constant Integer := Integer'Max (X + Effective_Radius, Clip.X_Min);
         Right  : constant Integer := Integer'Min (X2 - Effective_Radius, Clip.X_Max);
         Top    : constant Integer := Integer'Max (Y + Effective_Radius, Clip.Y_Min);
         Bottom : constant Integer := Integer'Min (Y2 - Effective_Radius, Clip.Y_Max);

         --  Corner positions (with clipping checks)
         TR_X : constant Integer := Integer'Min (X2 - Effective_Radius, Clip.X_Max);
         TR_Y : constant Integer := Integer'Max (Y + Effective_Radius, Clip.Y_Min);
         BR_X : constant Integer := Integer'Min (X2 - Effective_Radius, Clip.X_Max);
         BR_Y : constant Integer := Integer'Min (Y2 - Effective_Radius, Clip.Y_Max);
         BL_X : constant Integer := Integer'Max (X + Effective_Radius, Clip.X_Min);
         BL_Y : constant Integer := Integer'Min (Y2 - Effective_Radius, Clip.Y_Max);
         TL_X : constant Integer := Integer'Max (X + Effective_Radius, Clip.X_Min);
         TL_Y : constant Integer := Integer'Max (Y + Effective_Radius, Clip.Y_Min);
      begin
         --  Quick exit if radius is 0 (draw normal rectangle with clipping)
         if Effective_Radius = 0 then
            Draw_Line (Context,
                     Integer'Max (X, Clip.X_Min), Integer'Max (Y, Clip.Y_Min),
                     Integer'Min (X2, Clip.X_Max), Integer'Max (Y, Clip.Y_Min), Color);
            Draw_Line (Context,
                     Integer'Min (X2, Clip.X_Max), Integer'Max (Y, Clip.Y_Min),
                     Integer'Min (X2, Clip.X_Max), Integer'Min (Y2, Clip.Y_Max), Color);
            Draw_Line (Context,
                     Integer'Min (X2, Clip.X_Max), Integer'Min (Y2, Clip.Y_Max),
                     Integer'Max (X, Clip.X_Min), Integer'Min (Y2, Clip.Y_Max), Color);
            Draw_Line (Context,
                     Integer'Max (X, Clip.X_Min), Integer'Min (Y2, Clip.Y_Max),
                     Integer'Max (X, Clip.X_Min), Integer'Max (Y, Clip.Y_Min), Color);
            return;
         end if;

         --  Draw top and bottom lines (clipped)
         if Top <= Clip.Y_Max and then Left <= Clip.X_Max and then Right >= Clip.X_Min then
            Draw_Line (Context,
                     Integer'Max (Left, Clip.X_Min), Y,
                     Integer'Min (Right, Clip.X_Max), Y, Color);
         end if;

         if Bottom >= Clip.Y_Min and then Left <= Clip.X_Max and then Right >= Clip.X_Min then
            Draw_Line (Context,
                     Integer'Max (Left, Clip.X_Min), Y2,
                     Integer'Min (Right, Clip.X_Max), Y2, Color);
         end if;

         --  Draw left and right lines (clipped)
         if Left >= Clip.X_Min and then Top <= Clip.Y_Max and then Bottom >= Clip.Y_Min then
            Draw_Line (Context, X,
                     Integer'Max (Top, Clip.Y_Min),
                     X,
                     Integer'Min (Bottom, Clip.Y_Max), Color);
         end if;

         if Right <= Clip.X_Max and then Top <= Clip.Y_Max and then Bottom >= Clip.Y_Min then
            Draw_Line (Context, X2,
                     Integer'Max (Top, Clip.Y_Min),
                     X2,
                     Integer'Min (Bottom, Clip.Y_Max), Color);
         end if;

         --  Draw the four rounded corners (if they're within clip rectangle)
         if TR_X <= Clip.X_Max and then TR_Y >= Clip.Y_Min then
            Draw_Quarter_Circle (TR_X, TR_Y, Top_Right);
         end if;
         if BR_X <= Clip.X_Max and then BR_Y <= Clip.Y_Max then
            Draw_Quarter_Circle (BR_X, BR_Y, Bottom_Right);
         end if;
         if BL_X >= Clip.X_Min and then BL_Y <= Clip.Y_Max then
            Draw_Quarter_Circle (BL_X, BL_Y, Bottom_Left);
         end if;
         if TL_X >= Clip.X_Min and then TL_Y >= Clip.Y_Min then
            Draw_Quarter_Circle (TL_X, TL_Y, Top_Left);
         end if;
      end;
   end Draw_Rounded_Rectangle;

   --------------------------------------------------------------------------------
   --  Draw_Filled_Rounded_Rectangle
   --
   --  DESCRIPTION:
   --    Draws a filled rounded rectangle with the specified dimensions and corner radius.
   --    Uses a scanline approach with proper clipping.
   --
   --  PARAMETERS:
   --    Context    --  Render context containing the drawing buffer
   --    X, Y       --  Top-left corner coordinates
   --    Width      --  Width of the rectangle
   --    Height     --  Height of the rectangle
   --    Radius     --  Radius of the rounded corners
   --    Color      --  Color to use for filling the rectangle
   --------------------------------------------------------------------------------
   procedure Draw_Filled_Rounded_Rectangle (
      Context    : in out Render_Context;
      X, Y       : Integer;           --  Top-left corner coordinates
      Width      : Natural;           --  Width of the rectangle
      Height     : Natural;           --  Height of the rectangle
      Radius     : Natural;           --  Corner radius
      Color      : Pixel)
   is
      --  Get clip rectangle
      Clip : constant Clip_Rectangle := Current_Clip_Rect (Context);

      --  Calculate bounds
      X2 : constant Integer := X + Integer (Width) - 1;
      Y2 : constant Integer := Y + Integer (Height) - 1;

      --  Function to check if a point is inside the rounded rectangle
      function Is_Inside (Px, Py : Integer) return Boolean is
      begin
         --  Check against simple rectangle bounds first
         if Px < X or else Px > X2 or else Py < Y or else Py > Y2 then
            return False;
         end if;

         --  Calculate effective radius
         Effective_Radius : constant Integer := Integer'Min (Integer (Radius), Integer'Min (Integer (Width), Integer (Height)) / 2);

         --  Check against rounded corners if radius > 0
         if Effective_Radius > 0 then
            --  Top-left corner
            if Px <= X + Effective_Radius and then Py <= Y + Effective_Radius then
               return (Px - (X + Effective_Radius))**2 +
                     (Py - (Y + Effective_Radius))**2 <= Effective_Radius**2;
            --  Top-right corner
            elsif Px >= X2 - Effective_Radius and then Py <= Y + Effective_Radius then
               return (Px - (X2 - Effective_Radius))**2 +
                     (Py - (Y + Effective_Radius))**2 <= Effective_Radius**2;
            --  Bottom-left corner
            elsif Px <= X + Effective_Radius and then Py >= Y2 - Effective_Radius then
               return (Px - (X + Effective_Radius))**2 +
                     (Py - (Y2 - Effective_Radius))**2 <= Effective_Radius**2;
            --  Bottom-right corner
            elsif Px >= X2 - Effective_Radius and then Py >= Y2 - Effective_Radius then
               return (Px - (X2 - Effective_Radius))**2 +
                     (Py - (Y2 - Effective_Radius))**2 <= Effective_Radius**2;
            end if;
         end if;

         return True;
      end Is_Inside;

   begin
      --  Quick exit if completely outside clip rectangle
      if X2 < Clip.X_Min or else X > Clip.X_Max or else Y2 < Clip.Y_Min or else Y > Clip.Y_Max then
         return;
      end if;

      --  Calculate effective radius in executable section
      declare
         Effective_Radius : constant Integer := Integer'Min (Integer (Radius), Integer'Min (Integer (Width), Integer (Height)) / 2);
         Start_Y : constant Integer := Integer'Max (Y, Clip.Y_Min);
         End_Y   : constant Integer := Integer'Min (Y2, Clip.Y_Max);
         Start_X : constant Integer := Integer'Max (X, Clip.X_Min);
         End_X   : constant Integer := Integer'Min (X2, Clip.X_Max);
      begin
         --  Fill the rectangle with point-in-polygon check
         for Py in Start_Y .. End_Y loop
            for Px in Start_X .. End_X loop
               if Is_Inside (Px, Py) then
                  Put_Pixel (Context, Px, Py, Color);
               end if;
            end loop;
         end loop;
      end;
   end Draw_Filled_Rounded_Rectangle;

   --
   --  Compute the region code for a point (x, y)
   --
   function Compute_Out_Code
     (X, Y : Integer; X_Min, Y_Min, X_Max, Y_Max : Integer) return Out_Code
   is
      Code : Out_Code := [others => False];
   begin
      if X < X_Min then
         Code (Left) := True;
      elsif X > X_Max then
         Code (Right) := True;
      end if;

      if Y < Y_Min then
         Code (Bottom) := True;
      elsif Y > Y_Max then
         Code (Top) := True;
      end if;

      return Code;
   end Compute_Out_Code;

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
      Color  : Pixel)
   is
      Line_Accepted    : Boolean := False;
      Done             : Boolean := False;
      Out_Code0        : Out_Code;
      Out_Code1        : Out_Code;
      Out_Code_Out     : Out_Code;
      X_Start, Y_Start : Integer;
      X_End, Y_End     : Integer;
      X, Y             : Integer;
   begin
      --  Initialize local copies
      X_Start := X0;
      Y_Start := Y0;
      X_End := X1;
      Y_End := Y1;

      --  Compute region codes for both endpoints
      Out_Code0 :=
        Compute_Out_Code (X_Start, Y_Start, X_Min, Y_Min, X_Max, Y_Max);
      Out_Code1 := Compute_Out_Code (X_End, Y_End, X_Min, Y_Min, X_Max, Y_Max);

      loop
         --  Check if both endpoints are inside the clip rectangle
         if (not (Out_Code0 (Left)
                  or else Out_Code0 (Right)
                  or else Out_Code0 (Bottom)
                  or else Out_Code0 (Top)))
           and then
             (not (Out_Code1 (Left)
                   or else Out_Code1 (Right)
                   or else Out_Code1 (Bottom)
                   or else Out_Code1 (Top)))
         then
            Line_Accepted := True;
            Done := True;
         --  Check if both endpoints are outside in the same region
         elsif (Out_Code0 (Left) and then Out_Code1 (Left))
           or else (Out_Code0 (Right) and then Out_Code1 (Right))
           or else (Out_Code0 (Bottom) and then Out_Code1 (Bottom))
           or else (Out_Code0 (Top) and then Out_Code1 (Top))
         then
            Done := True;  --  Line is completely outside
         else
            --  Select an outside point
            if Out_Code0 (Left)
              or else Out_Code0 (Right)
              or else Out_Code0 (Bottom)
              or else Out_Code0 (Top)
            then
               Out_Code_Out := Out_Code0;
            else
               Out_Code_Out := Out_Code1;
            end if;

            --  Find intersection point
            --  Handle vertical lines to avoid division by zero
            if X_End = X_Start then
               if Out_Code_Out (Left) then
                  X := X_Min;
                  Y := Y_Start;
               elsif Out_Code_Out (Right) then
                  X := X_Max;
                  Y := Y_Start;
               elsif Out_Code_Out (Bottom) then
                  X := X_Start;
                  Y := Y_Min;
               elsif Out_Code_Out (Top) then
                  X := X_Start;
                  Y := Y_Max;
               end if;
            --  Handle horizontal lines to avoid division by zero
            elsif Y_End = Y_Start then
               if Out_Code_Out (Left) then
                  X := X_Min;
                  Y := Y_Start;
               elsif Out_Code_Out (Right) then
                  X := X_Max;
                  Y := Y_Start;
               elsif Out_Code_Out (Bottom) then
                  X :=
                    X_Start
                    + (X_End - X_Start)
                      * (Y_Min - Y_Start)
                      / Integer'Max (1, Y_End - Y_Start);
                  Y := Y_Min;
               elsif Out_Code_Out (Top) then
                  X :=
                    X_Start
                    + (X_End - X_Start)
                      * (Y_Max - Y_Start)
                      / Integer'Max (1, Y_End - Y_Start);
                  Y := Y_Max;
               end if;
            else
               --  Normal case for non-vertical, non-horizontal lines
               if Out_Code_Out (Left) then
                  --  Line clips left edge
                  X := X_Min;
                  Y :=
                    Y_Start
                    + (Y_End - Y_Start)
                      * (X_Min - X_Start)
                      / (X_End - X_Start);
               elsif Out_Code_Out (Right) then
                  --  Line clips right edge
                  X := X_Max;
                  Y :=
                    Y_Start
                    + (Y_End - Y_Start)
                      * (X_Max - X_Start)
                      / (X_End - X_Start);
               elsif Out_Code_Out (Bottom) then
                  --  Line clips bottom edge
                  Y := Y_Min;
                  X :=
                    X_Start
                    + (X_End - X_Start)
                      * (Y_Min - Y_Start)
                      / (Y_End - Y_Start);
               elsif Out_Code_Out (Top) then
                  --  Line clips top edge
                  Y := Y_Max;
                  X :=
                    X_Start
                    + (X_End - X_Start)
                      * (Y_Max - Y_Start)
                      / (Y_End - Y_Start);
               end if;
            end if;

            --  Now move outside point to intersection point
            if Out_Code_Out = Out_Code0 then
               X_Start := X;
               Y_Start := Y;
               Out_Code0 :=
                 Compute_Out_Code
                   (X_Start, Y_Start, X_Min, Y_Min, X_Max, Y_Max);
            else
               X_End := X;
               Y_End := Y;
               Out_Code1 :=
                 Compute_Out_Code (X_End, Y_End, X_Min, Y_Min, X_Max, Y_Max);
            end if;
         end if;

         exit when Done;
      end loop;

      if Line_Accepted then
         Draw_Line (B, X_Start, Y_Start, X_End, Y_End, Color);
      end if;
   end Draw_Clipped_Line;

   procedure Initialize_Gamma_Tables is
   begin
      --  sRGB -> Linear
      for I in Byte loop
         declare
            C : Float := Float (I) / 255.0;
         begin
            if C <= 0.04045 then
               Linear_From_sRGB (I) := C / 12.92;
            else
               Linear_From_sRGB (I) :=
               ((C + 0.055) / 1.055) ** 2.4;
            end if;
         end;
      end loop;

      --  Linear -> sRGB
      for I in sRGB_From_Linear'Range loop
         declare
            L : Float := Float (I) / 4095.0;
            S : Float;
         begin
            if L <= 0.0031308 then
               S := L * 12.92;
            else
               S := 1.055 * (L ** (1.0 / 2.4)) - 0.055;
            end if;

            sRGB_From_Linear (I) :=
            Byte (Float'Min (255.0,
                  Float'Max (0.0, S * 255.0)));
         end;
      end loop;
   end Initialize_Gamma_Tables;
begin
   Initialize_Gamma_Tables;
end Renderer;
