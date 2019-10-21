with Ada.Strings.Unbounded,
     --  Ocarina.Backends.Properties,
     TASTE.Interface_View;

package TASTE.Backend is
   use Ada.Strings.Unbounded,
       --  Ocarina.Backends.Properties,
       Interface_View;

   Backend_Error : exception;

   function Language_Spelling (Func : Taste_Terminal_Function) return String is
      (if    Func.Language = "ada"             then "Ada"
       elsif Func.Language = "c"               then "C"
       elsif Func.Language = "blackbox_device" then "Blackbox_C"
       elsif Func.Language = "gui"             then "GUI"
       elsif Func.Language = "cpp"             then "CPP"
       elsif Func.Language = "rtds"            then "RTDS"
       elsif Func.Language = "sdl"             then "SDL"
       elsif Func.Language = "sdl_opengeode"   then "SDL"
       elsif Func.Language = "simulink"        then "SIMULINK"
       elsif Func.Language = "qgenc"           then "QGenC"
       elsif Func.Language = "qgenada"         then "QGenAda"
       elsif Func.Language = "system_c"        then "System_C"
       elsif Func.Language = "vdm"             then "VDM"
       elsif Func.Language = "vhdl"            then "VHDL"
       elsif Func.Language = "vhdl_brave"      then "VHDL_BRAVE"
       elsif Func.Language = "micropython"     then "MicroPython"
       else  To_String (Func.Language));
end TASTE.Backend;
