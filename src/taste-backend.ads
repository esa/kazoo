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
       else                                         "None");
--     (case Func.Language is
--         when Language_Ada_95        => "Ada",
--         when Language_ASN1          => "ASN1",
--         when Language_C             => "C",
--         when Language_Esterel       => "Esterel",     --  Not supported
--         when Language_Device        => "Blackbox_C",
--         when Language_Gui           => "GUI",
--         when Language_Lua           => "Lua",         --  Not supported
--         when Language_Lustre        => "SCADE",       --  Not supported
--         when Language_Rhapsody      => "CPP",
--         when Language_SDL_RTDS      => "RTDS",        --  Pragmadev Studio
--         when Language_CPP           => "CPP",
--         when Language_SDL_OpenGEODE => "SDL",
--         when Language_RTSJ          => "RTSJ",        --  Not supported
--         when Language_Scade         => "SCADE",       --  Not supported
--         when Language_SDL           => "SDL",
--         when Language_Simulink      => "SIMULINK",
--         when Language_QGenC         => "QGenC",
--         when Language_QGenAda       => "QGenAda",
--         when Language_System_C      => "System_C",    --  Not supported
--         when Language_VDM           => "VDM",         --  Partial support
--         when Language_VHDL          => "VHDL",
--         when Language_VHDL_BRAVE    => "VHDL_BRAVE",
--         when Language_MicroPython   => "MicroPython",
--         when Language_None          => "None");
end TASTE.Backend;
