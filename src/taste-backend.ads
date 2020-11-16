with Ada.Strings.Unbounded,
     --  Ocarina.Backends.Properties,
     TASTE.Interface_View;

package TASTE.Backend is
   use Ada.Strings.Unbounded,
       --  Ocarina.Backends.Properties,
       Interface_View;

   Backend_Error : exception;

   function Map_Language (Language : String) return String is
     (if    Language = "ada"             then "Ada"
      elsif Language = "c"               then "C"
      elsif Language = "blackbox_device" then "Blackbox_C"
      elsif Language = "gui"             then "GUI"
      elsif Language = "cpp"             then "CPP"
      elsif Language = "rtds"            then "RTDS"
      elsif Language = "sdl"             then "SDL"
      elsif Language = "sdl_opengeode"   then "SDL"
      elsif Language = "simulink"        then "SIMULINK"
      elsif Language = "qgenc"           then "QGenC"
      elsif Language = "qgenada"         then "QGenAda"
      elsif Language = "system_c"        then "System_C"
      elsif Language = "vdm"             then "VDM"
      elsif Language = "vhdl"            then "VHDL"
      elsif Language = "vhdl_brave"      then "VHDL_BRAVE"
      elsif Language = "micropython"     then "MicroPython"
      else Language);

   function Language_Spelling (Func : Taste_Terminal_Function) return String is
      (Map_Language (To_String (Func.Language)));
end TASTE.Backend;
