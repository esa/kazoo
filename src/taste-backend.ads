with Ocarina.Backends.Properties,
     TASTE.Interface_View;

package TASTE.Backend is
   use Ocarina.Backends.Properties,
       Interface_View;

   Backend_Error : exception;

   function Language_Spelling (Func : Taste_Terminal_Function) return String is
      (case Func.Language is
          when Language_Ada_95        => "Ada",
          when Language_ASN1          => "ASN1",
          when Language_C             => "C",
          when Language_Esterel       => "Esterel",     --  Not supported
          when Language_Device        => "C",
          when Language_Gui           => "GUI",
          when Language_Lua           => "Lua",         --  Not supported
          when Language_Lustre        => "SCADE",       --  Not supported
          when Language_Rhapsody      => "CPP",
          when Language_SDL_RTDS      => "RTDS",        --  Pragmadev Studio
          when Language_CPP           => "CPP",
          when Language_SDL_OpenGEODE => "SDL",
          when Language_RTSJ          => "RTSJ",        --  Not supported
          when Language_Scade         => "SCADE",       --  Not supported
          when Language_SDL           => "SDL",
          when Language_Simulink      => "SIMULINK",
          when Language_QGenC         => "QGenC",
          when Language_QGenAda       => "QGenAda",
          when Language_System_C      => "System_C",    --  Not supported
          when Language_VDM           => "VDM",         --  Partial support
          when Language_VHDL          => "VHDL",
          when Language_MicroPython   => "MicroPython",
          when Language_None          => "None");
end TASTE.Backend;
