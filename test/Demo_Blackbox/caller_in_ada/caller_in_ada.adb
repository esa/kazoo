-- User implementation of the caller_in_ada function
-- This file will never be overwritten once edited and modified
-- Only the interface of functions is regenerated (in the .ads file)
with adaasn1rtl;
use adaasn1rtl;

with taste_dataview;
use taste_dataview;

with system.io;

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

            RunDriver(i1, i2, o1, o2);
            system.io.put("[Ada] i1=");
            system.io.put(asn1sccMyInteger'image(i1));
            system.io.put(" i2=");
            system.io.put(asn1sccMyInteger'image(i2));
            system.io.put(" o1=");
            system.io.put(asn1sccMyInteger'image(o1));
            system.io.put(" o2=");
            system.io.put(asn1sccMyInteger'image(o2));
            if i1 /= o2 or i2 /= o1 then
                system.io.put_line("[...ERROR!");
            else system.io.put_line("...OK");
            end if;
            i1 := i1 + 1; 
            i2 := i2 + 1;

        end pulse;
        begin
            system.io.put_line("[Ada] startup");

end caller_in_ada;
