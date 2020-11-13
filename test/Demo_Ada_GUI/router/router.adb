-- User implementation of the router function
-- This file will never be overwritten once edited and modified
-- Only the interface of functions is regenerated (in the .ads file)

pragma style_checks (off);
pragma warnings (off);

with adaasn1rtl;
use adaasn1rtl;

with dataview;
use dataview;

with system.io;

package body router is
    ---------------------------------------------------------
    -- Provided interface "router_put_tc"
    ---------------------------------------------------------
    procedure Router_Put_TC (TC : in out asn1SccTC_T) is
    begin
       Displayer_Put_TC (TC);
    end router_put_tc;

    ---------------------------------------------------------
    -- Provided interface "router_send_tm"
    ---------------------------------------------------------
    procedure router_send_tm(tm: in out asn1SccTM_T) is
    begin
       gui_send_tm(tm);
    end router_send_tm;
begin
   system.io.put_line ("init of router done");
end router;
