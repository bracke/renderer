with AUnit.Simple_Test_Cases; use AUnit.Simple_Test_Cases;
with Basic;
with Radius;
with Misc_Test;
with Rounded_Rectangle_1;
with Rounded_Rectangle_2;
with Rounded_Rectangle_3;
with Bootstrap;
with Debug;

package body Misc_Suite is

   function Suite return Access_Test_Suite is
      Ret : constant Access_Test_Suite := new Test_Suite;
   begin
      Ret.Add_Test (Test_Case_Access'(new Debug.Test));
   --   Ret.Add_Test (Test_Case_Access'(new Basic.Test));
     -- Ret.Add_Test (Test_Case_Access'(new Radius.Test));
      --  Ret.Add_Test (Test_Case_Access'(new Misc_Test.Test));
      --  Ret.Add_Test (Test_Case_Access'(new Rounded_Rectangle_1.Test));
      --  Ret.Add_Test (Test_Case_Access'(new Rounded_Rectangle_2.Test));
      --  Ret.Add_Test (Test_Case_Access'(new Rounded_Rectangle_3.Test));
      --  Ret.Add_Test (Test_Case_Access'(new Bootstrap.Test));
      return Ret;
   end Suite;

end Misc_Suite;