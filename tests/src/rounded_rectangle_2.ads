with AUnit;
with AUnit.Simple_Test_Cases;

package Rounded_Rectangle_2 is

   type Test is new AUnit.Simple_Test_Cases.Test_Case with null record;

   overriding function Name (T : Test) return AUnit.Message_String;

   overriding procedure Run_Test (T : in out Test);

end Rounded_Rectangle_2;