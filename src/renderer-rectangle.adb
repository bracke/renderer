pragma Ada_2022;
pragma Extensions_Allowed (All_Extensions);

with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics;                        use Ada.Numerics;

package body Renderer.Rectangle is

   --------------------------------------------------
   -- Clamp function
   --------------------------------------------------
   function Clamp(V, Lo, Hi : Float) return Float is
   begin
      if V < Lo then
         return Lo;
      elsif V > Hi then
         return Hi;
      else
         return V;
      end if;
   end Clamp;

   --------------------------------------------------
   -- Gamma-correct interpolation
   --------------------------------------------------
   function Interpolate_Color(C0, C1 : Pixel; T : Float) return Pixel is
      Result : Pixel;
      R0 : Float := Linear_From_sRGB(C0.R);
      G0 : Float := Linear_From_sRGB(C0.G);
      B0 : Float := Linear_From_sRGB(C0.B);
      R1 : Float := Linear_From_sRGB(C1.R);
      G1 : Float := Linear_From_sRGB(C1.G);
      B1 : Float := Linear_From_sRGB(C1.B);
      RL, GL, BL : Float;
      Index : Integer;
      SRGB_SCALE : constant Float := 4095.0;
   begin
      RL := R0 + (R1 - R0) * T;
      GL := G0 + (G1 - G0) * T;
      BL := B0 + (B1 - B0) * T;

      Index := Integer(Clamp(RL*SRGB_SCALE,0.0,SRGB_SCALE));
      Result.R := sRGB_From_Linear(Index);
      Index := Integer(Clamp(GL*SRGB_SCALE,0.0,SRGB_SCALE));
      Result.G := sRGB_From_Linear(Index);
      Index := Integer(Clamp(BL*SRGB_SCALE,0.0,SRGB_SCALE));
      Result.B := sRGB_From_Linear(Index);

      Result.A := Byte(Clamp(Float(C0.A) + (Float(C1.A) - Float(C0.A)) * T, 0.0, 255.0));

      return Result;
   end Interpolate_Color;

   --------------------------------------------------
   -- Sample Gradient
   --------------------------------------------------
   function Sample_Gradient(G : Gradient; PX, PY : Float) return Pixel is
      T : Float := 0.0;
      DX, DY, Len, R, Angle, Dist : Float;
      Two_Pi : constant Float := 2.0*Pi;
   begin
      case G.Kind is
         when Solid =>
            return G.Stops(1).Color;
         when Linear =>
            DX := G.X2 - G.X1;
            DY := G.Y2 - G.Y1;
            Len := Sqrt(DX*DX + DY*DY);
            if Len /= 0.0 then
               T := ((PX - G.X1)*DX + (PY - G.Y1)*DY)/(Len*Len);
            else
               T := 0.0;
            end if;
         when Radial =>
            DX := PX - G.CX;
            DY := PY - G.CY;
            R := Sqrt(DX*DX + DY*DY);
            if G.Radius /= 0.0 then
               T := R / G.Radius;
            else
               T := 0.0;
            end if;
         when Conic =>
            DX := PX - G.CX;
            DY := PY - G.CY;
            Angle := Arctan(DY, DX) + G.Angle_Offset;
            if Angle < 0.0 then
               Angle := Angle + Two_Pi;
            end if;
            while Angle >= Two_Pi loop
               Angle := Angle - Two_Pi;
            end loop;
            T := Angle / Two_Pi;
      end case;

      -- Repeat handling
      if G.Repeat and then G.Repeat_Length > 0.0 then
         case G.Kind is
            when Linear =>
               DX := G.X2 - G.X1;
               DY := G.Y2 - G.Y1;
               Len := Sqrt(DX*DX + DY*DY);
               Dist := T*Len;
               Dist := Float'Remainder(Dist, G.Repeat_Length);
               if Dist < 0.0 then Dist := Dist + G.Repeat_Length; end if;
               T := Dist / G.Repeat_Length;
            when Radial =>
               DX := PX - G.CX;
               DY := PY - G.CY;
               R := Sqrt(DX*DX + DY*DY);
               R := Float'Remainder(R, G.Repeat_Length);
               if R < 0.0 then R := R + G.Repeat_Length; end if;
               T := R / G.Repeat_Length;
            when Conic =>
               Angle := T*Two_Pi;
               Angle := Float'Remainder(Angle, G.Repeat_Length);
               if Angle < 0.0 then Angle := Angle + G.Repeat_Length; end if;
               T := Angle / G.Repeat_Length;
            when others => null;
         end case;
      end if;

      T := Clamp(T,0.0,1.0);

      for I in G.Stops'Range loop
         if I /= G.Stops'Last then
            declare
               S0 : Gradient_Stop := G.Stops(I);
               S1 : Gradient_Stop := G.Stops(I+1);
               Local_T : Float;
            begin
               if T >= S0.Position and then T <= S1.Position then
                  Local_T := (T - S0.Position)/(S1.Position - S0.Position);
                  return Interpolate_Color(S0.Color, S1.Color, Local_T);
               end if;
            end;
         end if;
      end loop;

      return G.Stops(G.Stops'Last).Color;
   end Sample_Gradient;

   --------------------------------------------------
   -- Blend Pixel
   --------------------------------------------------
   procedure Blend_Pixel(Dst : in out Pixel; Src : Pixel; Coverage : Float) is
      Src_A : Float := Float(Src.A)/255.0*Coverage;
      Dst_A : Float := Float(Dst.A)/255.0;
      Out_A : Float;
      function Blend_Channel(S,D:Byte; SA,DA,OA:Float) return Byte is
         S_F : Float := Float(S)/255.0;
         D_F : Float := Float(D)/255.0;
         Val : Float;
      begin
         if OA=0.0 then return 0; end if;
         Val := (S_F*SA + D_F*DA*(1.0-SA))/OA;
         return Byte(Clamp(Val*255.0,0.0,255.0));
      end Blend_Channel;
   begin
      Out_A := Src_A + Dst_A*(1.0-Src_A);
      Dst.R := Blend_Channel(Src.R,Dst.R,Src_A,Dst_A,Out_A);
      Dst.G := Blend_Channel(Src.G,Dst.G,Src_A,Dst_A,Out_A);
      Dst.B := Blend_Channel(Src.B,Dst.B,Src_A,Dst_A,Out_A);
      Dst.A := Byte(Clamp(Out_A*255.0,0.0,255.0));
   end Blend_Pixel;

   --------------------------------------------------
   -- Clamp radii
   --------------------------------------------------
   function Clamp_Radius(R, W, H : Float) return Float is
   begin
      return Float'Min(R, Float'Min(W/2.0, H/2.0));
   end Clamp_Radius;

   --------------------------------------------------
   -- Rounded rectangle distance
   --------------------------------------------------
  function Rounded_Rect_Distance(
   PX, PY       : Float;
   X, Y         : Integer;
   Width, Height: Natural;
   Radius_TL, Radius_TR, Radius_BR, Radius_BL: Natural
) return Float is
   Local_X : Float := PX - Float(X);
   Local_Y : Float := PY - Float(Y);
   DX, DY, AX, AY : Float;
   R_TL, R_TR, R_BR, R_BL, R_Selected : Float;
begin
   -- Clamp radii
   R_TL := Clamp_Radius(Float(Radius_TL), Float(Width), Float(Height));
   R_TR := Clamp_Radius(Float(Radius_TR), Float(Width), Float(Height));
   R_BR := Clamp_Radius(Float(Radius_BR), Float(Width), Float(Height));
   R_BL := Clamp_Radius(Float(Radius_BL), Float(Width), Float(Height));

   -- Select corner radius based on quadrant
   if Local_X < R_TL and Local_Y < R_TL then
      R_Selected := R_TL;
   elsif Local_X >= Float(Width) - R_TR and Local_Y < R_TR then
      R_Selected := R_TR;
   elsif Local_X >= Float(Width) - R_BR and Local_Y >= Float(Height) - R_BR then
      R_Selected := R_BR;
   elsif Local_X < R_BL and Local_Y >= Float(Height) - R_BL then
      R_Selected := R_BL;
   else
      R_Selected := 0.0;
   end if;

   -- Compute distance from rectangle edges with rounded corner
   DX := Abs(Local_X - Float(Width)/2.0) - Float(Width)/2.0 + R_Selected;
   DY := Abs(Local_Y - Float(Height)/2.0) - Float(Height)/2.0 + R_Selected;

   AX := Float'Max(DX, 0.0);
   AY := Float'Max(DY, 0.0);

   return Sqrt(AX*AX + AY*AY) + Float'Min(Float'Max(DX,DY),0.0) - R_Selected;
end Rounded_Rect_Distance;
   --------------------------------------------------
   -- Gaussian kernel
   --------------------------------------------------
   type Gaussian_Kernel is array (Natural range <>) of Float;

   function Build_Gaussian_Kernel(Radius : Natural) return Gaussian_Kernel is
      Kernel : Gaussian_Kernel(0 .. 2*Radius);
      Sigma  : Float := Float(Radius)/2.0;
      Sum    : Float := 0.0;
      X : Float;
   begin
      for I in Kernel'Range loop
         X := Float(I) - Float(Radius);
         Kernel(I) := Exp(-(X*X)/(2.0*Sigma*Sigma));
         Sum := Sum + Kernel(I);
      end loop;

      for I in Kernel'Range loop
         Kernel(I) := Kernel(I)/Sum;
      end loop;

      return Kernel;
   end Build_Gaussian_Kernel;

   --------------------------------------------------
   -- Draw Rounded Rectangle with Shadows
   --------------------------------------------------
procedure Draw_Rounded_Rectangle
    (Context  : in out Render_Context;
   Geometry : Rectangle_Geometry;
   Style    : Rectangle_Style) is

   -- Geometry unpacking
   X      : constant Integer := Geometry.X;
   Y      : constant Integer := Geometry.Y;
   Width  : constant Natural := Geometry.Width;
   Height : constant Natural := Geometry.Height;

   -- Radii unpacking
   Radius_TL : constant Natural := Style.Radii.TL;
   Radius_TR : constant Natural := Style.Radii.TR;
   Radius_BR : constant Natural := Style.Radii.BR;
   Radius_BL : constant Natural := Style.Radii.BL;

   -- Border unpacking
   Border_Size : constant Natural := Style.Border.Size;
   Border_F    : constant Float   := Float(Border_Size);

   Clip : constant Clip_Rectangle := Current_Clip_Rect(Context);
   AA_Width : constant Float := 1.0;

   X_Start : constant Integer :=
     Integer'Max(0, X - Integer(Border_Size) - 2);

   Y_Start : constant Integer :=
     Integer'Max(0, Y - Integer(Border_Size) - 2);

   X_End : constant Integer :=
     Integer'Min(Integer(Context.Max_X),
                 X + Integer(Width) + Integer(Border_Size) + 2);

   Y_End : constant Integer :=
     Integer'Min(Integer(Context.Max_Y),
                 Y + Integer(Height) + Integer(Border_Size) + 2);

   X_Min : constant Integer := Integer'Max(X_Start, Clip.X_Min);
   Y_Min : constant Integer := Integer'Max(Y_Start, Clip.Y_Min);
   X_Max : constant Integer := Integer'Min(X_End,   Clip.X_Max);
   Y_Max : constant Integer := Integer'Min(Y_End,   Clip.Y_Max);

   --------------------------------------------------
   -- Distance → alpha helper
   --------------------------------------------------
   function Alpha_From_Dist(Dist : Float) return Float is
   begin
      return Clamp(0.5 - Dist / AA_Width, 0.0, 1.0);
   end Alpha_From_Dist;

   --------------------------------------------------
   -- Rounded rectangle shadow procedure
   --------------------------------------------------
procedure Draw_Shadows is
   Temp_Alpha : array (X_Min .. X_Max, Y_Min .. Y_Max) of Float := (others => (others => 0.0));
   H_Buffer   : array (X_Min .. X_Max, Y_Min .. Y_Max) of Float := (others => (others => 0.0));
   Sum        : Float;
   SX, SY     : Integer;
begin
   for S in Style.Shadows'Range loop
      declare
         Shadow : constant Shadow_Params := Style.Shadows(S);
         Kernel : constant Gaussian_Kernel := Build_Gaussian_Kernel(Shadow.Blur);
         Kernel_Center : constant Integer := Integer(Shadow.Blur);
      begin
         -- Step 1: Compute alpha mask from rectangle SDF + spread
         for PY in Y_Min .. Y_Max loop
            for PX in X_Min .. X_Max loop
               declare
                  Dist  : Float := Rounded_Rect_Distance(
                                    Float(PX) + 0.5 - Float(X) - Float(Shadow.Offset_X),
                                    Float(PY) + 0.5 - Float(Y) - Float(Shadow.Offset_Y),
                                    X, Y, Width, Height,
                                    Radius_TL, Radius_TR, Radius_BR, Radius_BL);
                  Alpha : Float;
               begin
                  -- Convert distance to alpha using blur and spread
                  Alpha := Clamp((Float(Shadow.Blur) - Dist + Float(Shadow.Spread)) / Float(Shadow.Blur), 0.0, 1.0);
                  Temp_Alpha(PX,PY) := Alpha;
               end;
            end loop;
         end loop;

         -- Step 2: Horizontal Gaussian blur
         for PY in Y_Min .. Y_Max loop
            for PX in X_Min .. X_Max loop
               Sum := 0.0;
               for K in Kernel'Range loop
                  SX := PX + Integer(K) - Kernel_Center;
                  if SX >= X_Min and then SX <= X_Max then
                     Sum := Sum + Temp_Alpha(SX,PY) * Kernel(K);
                  end if;
               end loop;
               H_Buffer(PX,PY) := Sum;
            end loop;
         end loop;

         -- Step 3: Vertical Gaussian blur + blend
         for PY in Y_Min .. Y_Max loop
            for PX in X_Min .. X_Max loop
               Sum := 0.0;
               for K in Kernel'Range loop
                  SY := PY + Integer(K) - Kernel_Center;
                  if SY >= Y_Min and then SY <= Y_Max then
                     Sum := Sum + H_Buffer(PX,SY) * Kernel(K);
                  end if;
               end loop;

               if Sum > 0.0 then
                  declare
                     P : Pixel renames Context.The_Buffer(Natural(PX), Natural(PY));
                  begin
                     Blend_Pixel(P, Shadow.Color, Sum);
                  end;
               end if;
            end loop;
         end loop;
      end;
   end loop;
end Draw_Shadows;

begin
   -- Draw shadows first
   Draw_Shadows;

   -- Draw rectangle fill and border
   for PY in Y_Min .. Y_Max loop
      for PX in X_Min .. X_Max loop
         declare
            P : Pixel renames Context.The_Buffer(Natural(PX), Natural(PY));
            Dist : Float := Rounded_Rect_Distance(Float(PX)+0.5, Float(PY)+0.5,
                                                 X,Y,Width,Height,
                                                 Radius_TL,Radius_TR,Radius_BR,Radius_BL);
            Alpha_Fill   : Float := Alpha_From_Dist(Dist);
            Alpha_Border : Float := 0.0;
         begin
            -- Border alpha
            if Border_Size > 0 then
               declare
                  Dist_Inner : Float := Dist;
                  Dist_Outer : Float := Dist - Border_F;
               begin
                  Alpha_Border := Clamp(Alpha_From_Dist(Dist_Outer) - Alpha_From_Dist(Dist_Inner), 0.0, 1.0);
               end;
            end if;

            -- Fill
            if Alpha_Fill > 0.0 then
               Blend_Pixel(P, Sample_Gradient(Style.Fill, Float(PX)+0.5, Float(PY)+0.5), Alpha_Fill);
            end if;

            -- Border
            if Alpha_Border > 0.0 then
               Blend_Pixel(P, Style.Border.Color, Alpha_Border);
            end if;
         end;
      end loop;
   end loop;

end Draw_Rounded_Rectangle;

end Renderer.Rectangle;