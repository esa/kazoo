-- User implementation of the caller_in_ada function
-- This file will never be overwritten once edited and modified
-- Only the interface of functions is regenerated (in the .ads file)

with Text_IO; use Text_IO;

with interfaces;
use interfaces;

package body caller_in_ada is
        i1: asn1sccMyInteger := 0;
        i2: asn1SccMyInteger := 1;
        o1: asn1SccMyInteger;
        o2: asn1SccMyInteger;


        ---------------------------------------------------------
        -- Provided interface "pulse"
        ---------------------------------------------------------
        procedure pulse is
        begin
            Put_Line ("[Ada] Calling in Ada");

            RunDriver(i1, i2, o1, o2);
            Put ("[Ada] i1=");
            Put (asn1sccMyInteger'image(i1));
            Put (" i2=");
            Put (asn1sccMyInteger'image(i2));
            Put (" o1=");
            Put (asn1sccMyInteger'image(o1));
            Put (" o2=");
            Put (asn1sccMyInteger'image(o2));
            if i1 /= o2 or i2 /= o1 then
                Put_Line("[...ERROR!");
            else Put_Line("...OK");
            end if;
            i1 := i1 + 1; 
            i2 := i2 + 1;

        end pulse;
        begin
            Put_line("[Ada] startup");

end caller_in_ada;
