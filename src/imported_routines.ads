--  ************************ taste aadl parser ****************************  --
--  (c) 2015 European Space Agency - maxime.perrotin@esa.int
--  LGPL license, see LICENSE file

with Ocarina.Types; use Ocarina.Types;
--  with Types; use Types;

package Imported_Routines is

   procedure C_Set_OutDir (Dir : String; Len : Integer);
   procedure C_Set_Stack  (Val : String; Len : Integer);
   procedure C_Set_Timer_Resolution  (Val : String; Len : Integer);
   procedure C_New_APLC   (Arg : String; Len : Integer);
   procedure C_New_FV     (Arg : String; Len : Integer; CS : String);

   procedure C_Set_PolyORBHI_C;

   procedure C_Add_PI (Arg : String;
                       Len : Integer);

   procedure C_Add_RI (Arg : String;
                       Len : Integer;
                       DistFV : String;
                       DLen : Integer;
                       DistName : String;
                       DistNameLen : Integer);

   procedure C_Set_Distant_APLC (Arg : String; Len : Integer);
   procedure C_End_IF;
   procedure C_End_FV;

   procedure C_Set_Root_Node (Arg : String; Len : Integer);

   procedure C_New_Process (Arg           : String;
                            Len           : Integer;
                            Id            : String;
                            LenId         : Integer;
                            Node_Name     : String;
                            Len_Node      : Integer;
                            Coverage      : Integer);

   procedure C_New_Processor (Name           : String;
                              Name_Len       : Integer;
                              Classifier     : String;
                              Classifier_Len : Integer;
                              Platform       : String;
                              Platform_Len   : Integer);

   procedure C_New_Bus (Name           : String;
                        Name_Len       : Integer;
                        Classifier     : String;
                        Classifier_Len : Integer);

   procedure C_New_Device (Name                         : String;
                           Name_Len                     : Integer;
                           Classifier                   : String;
                           Classifier_Len               : Integer;
                           Associated_Processor         : String;
                           Associated_Processor_Len     : Integer;
                           Configuration                : String;
                           Configuration_Len            : Integer;
                           Accessed_Bus                 : String;
                           Accessed_Bus_Len             : Integer;
                           Access_Port                  : String;
                           Access_Port_Len              : Integer;
                           Asn1_Filename                : String;
                           Asn1_Filename_Len            : Integer;
                           Asn1_Typename                : String;
                           Asn1_Typename_Len            : Integer;
                           Asn1_Modulename              : String;
                           Asn1_Modulename_Len          : Integer);

   procedure C_New_Connection (Src_System          : String;
                               Src_System_Length   : Integer;
                               Src_Port            : String;
                               Src_Port_Length     : Integer;
                               Bus                 : String;
                               Bus_Length          : Integer;
                               Dst_System          : String;
                               Dst_System_Length   : Integer;
                               Dst_Port            : String;
                               Dst_Port_Length     : Integer);

   procedure C_Add_Binding (Arg : String; Len : Integer);
   procedure C_End_Process;
   procedure C_End_Bus;
   procedure C_End_Device;
   procedure C_End_Connection;
   procedure C_Add_In_Param
     (name     : String;
      Len1     : Integer;
      partype  : String;
      Len2     : Integer;
      module   : String;
      Len3     : Integer;
      filename : String;
      Len4     : Integer);
   procedure C_Add_Out_Param
     (name     : String;
      Len1     : Integer;
      partype  : String;
      Len2     : Integer;
      module   : String;
      Len3     : Integer;
      filename : String;
      Len4     : Integer);
   procedure C_Add_Package
     (Name    : String;
      Len     : Integer);
   procedure C_Set_Compute_Time
     (Lower_Bound    : Unsigned_Long_Long;
      Lower_Unit     : String;
      Len2           : Integer;
      Upper_Bound    : Unsigned_Long_Long;
      Upper_Unit     : String;
      Len4           : Integer);
   procedure C_Set_Context_Variable
     (varName : String;
      nameLen : Integer;
      varType : String;
      typeLen : Integer;
      varVal  : String;
      valLen  : Integer;
      varMod  : String;
      modLen  : Integer;
      varFile : String;
      fileLen : Integer;
      fullName : String);
   procedure C_Set_Period (Period : Unsigned_Long_Long);
   procedure C_Set_Interface_Queue_Size (Size : Unsigned_Long_Long);
   procedure C_Set_Glue;
   procedure C_Set_SMP2;
   procedure C_Set_Interfaceview
     (name : String;
      len  : Integer);
   procedure C_Set_Dataview
     (name : String;
      len  : Integer);
   procedure C_Set_Zipfile
      (name : String;
       len  : Integer);
   procedure C_Set_Gateway;
   procedure C_Keep_case;
   procedure C_Set_Test;
   procedure C_Set_Future;
   procedure C_Set_OnlyCV;
   procedure C_Set_AADLV2;
   procedure C_Set_Language_To_SDL;
   procedure C_Set_Language_To_Simulink;
   procedure C_Set_Language_To_Other;
   procedure C_Set_Language_To_C;
   procedure C_Set_Language_To_QGenAda;
   procedure C_Set_Language_To_QGenC;
   procedure C_Set_Language_To_CPP;
   procedure C_Set_Language_To_VDM;
   procedure C_Set_Language_To_OpenGEODE;
   procedure C_Set_Language_To_BlackBox_Device;
   procedure C_Set_Language_To_RTDS;
   procedure C_Set_Language_To_Rhapsody;
   procedure C_Set_Language_To_Scade;
   procedure C_Set_Language_To_Ada;
   procedure C_Set_Language_To_GUI;
   procedure C_Set_Language_To_VHDL;
   procedure C_Set_Language_To_System_C;
   procedure C_Set_Native_Encoding;
   procedure C_Set_UPER_Encoding;
   procedure C_Set_ACN_Encoding;
   procedure C_Set_Sync_IF;
   procedure C_Set_ASync_IF;
   procedure C_Set_Unknown_IF;
   procedure C_Set_Cyclic_IF;
   procedure C_Set_Sporadic_IF;
   procedure C_Set_Variator_IF;
   procedure C_Set_Protected_IF;
   procedure C_Set_Unprotected_IF;
   procedure C_Set_UndefinedKind_IF;
   procedure C_Init;
   procedure C_End;
   procedure C_Set_ASN1_BasicType_Sequence;
   procedure C_Set_ASN1_BasicType_SequenceOf;
   procedure C_Set_ASN1_BasicType_Enumerated;
   procedure C_Set_ASN1_BasicType_Set;
   procedure C_Set_ASN1_BasicType_SetOf;
   procedure C_Set_ASN1_BasicType_Integer;
   procedure C_Set_ASN1_BasicType_Boolean;
   procedure C_Set_ASN1_BasicType_Real;
   procedure C_Set_ASN1_BasicType_Choice;
   procedure C_Set_ASN1_BasicType_String;
   procedure C_Set_ASN1_BasicType_Unknown;
   procedure C_Set_ASN1_BasicType_OctetString;
   procedure C_Set_Debug_Messages;
   procedure C_New_Drivers_Section;
   procedure C_End_Drivers_Section;

private
   pragma Import (C, C_New_Drivers_Section, "New_Drivers_Section");
   pragma Import (C, C_End_Drivers_Section, "End_Drivers_Section");
   pragma Import (C, C_Set_PolyORBHI_C, "Set_PolyorbHI_C");
   pragma Import (C, C_Set_Root_Node, "Set_Root_Node");
   pragma Import (C, C_New_Process, "New_Process");
   pragma Import (C, C_New_Connection, "New_Connection");
   pragma Import (C, C_New_Processor, "New_Processor");
   pragma Import (C, C_New_Bus, "New_Bus");
   pragma Import (C, C_New_Device, "New_Device");
   pragma Import (C, C_Add_Binding, "Add_Binding");
   pragma Import (C, C_End_Process, "End_Process");
   pragma Import (C, C_End_Bus, "End_Bus");
   pragma Import (C, C_End_Device, "End_Device");
   pragma Import (C, C_End_Connection, "End_Connection");
   pragma Import (C, C_Init, "C_Init");
   pragma Import (C, C_End, "C_End");
   pragma Import (C, C_Set_OutDir, "Set_OutDir");
   pragma Import (C, C_Set_Interfaceview, "Set_Interfaceview");
   pragma Import (C, C_Set_Dataview, "Set_Dataview");
   pragma Import (C, C_Set_Stack, "Set_Stack");
   pragma Import (C, C_Set_Timer_Resolution, "Set_Timer_Resolution");
   pragma Import (C, C_New_APLC, "New_APLC");
   pragma Import (C, C_New_FV, "New_FV");
   pragma Import (C, C_Add_PI, "Add_PI");
   pragma Import (C, C_Add_RI, "Add_RI");
   pragma Import (C, C_Set_Distant_APLC, "Set_Distant_APLC");
   pragma Import (C, C_End_IF, "End_IF");
   pragma Import (C, C_End_FV, "End_FV");
   pragma Import (C, C_Add_In_Param, "Add_In_Param");
   pragma Import (C, C_Add_Out_Param, "Add_Out_Param");
   pragma Import (C, C_Set_Glue, "Set_Glue");
   pragma Import (C, C_Set_SMP2, "Set_SMP2");
   pragma Import (C, C_Set_Gateway, "Set_Gateway");
   pragma Import (C, C_Keep_case, "Set_keep_case");
   pragma Import (C, C_Set_Test, "Set_Test");
   pragma Import (C, C_Set_Future, "Set_Future");
   pragma Import (C, C_Set_OnlyCV, "Set_OnlyCV");
   pragma Import (C, C_Set_AADLV2, "Set_AADLV2");
   pragma Import (C, C_Set_Language_To_SDL, "Set_Language_To_SDL");
   pragma Import (C, C_Set_Language_To_Simulink, "Set_Language_To_Simulink");
   pragma Import (C, C_Set_Language_To_Other, "Set_Language_To_Other");
   pragma Import (C, C_Set_Language_To_C, "Set_Language_To_C");
   pragma Import (C, C_Set_Language_To_CPP, "Set_Language_To_CPP");
   pragma Import (C, C_Set_Language_To_VDM, "Set_Language_To_VDM");
   pragma Import (C, C_Set_Language_To_OpenGEODE, "Set_Language_To_SDL");
   pragma Import (C, C_Set_Language_To_BlackBox_Device,
     "Set_Language_To_BlackBox_Device");
   pragma Import (C, C_Set_Language_To_RTDS, "Set_Language_To_RTDS");
   pragma Import (C, C_Set_Language_To_Rhapsody, "Set_Language_To_Rhapsody");
   pragma Import (C, C_Set_Language_To_Ada, "Set_Language_To_Ada");
   pragma Import (C, C_Set_Language_To_QGenAda, "Set_Language_To_QGenAda");
   pragma Import (C, C_Set_Language_To_QGenC, "Set_Language_To_QGenC");
   pragma Import (C, C_Set_Language_To_Scade, "Set_Language_To_Scade");
   pragma Import (C, C_Set_Language_To_GUI, "Set_Language_To_GUI");
   pragma Import (C, C_Set_Language_To_VHDL, "Set_Language_To_VHDL");
   pragma Import (C, C_Set_Language_To_System_C, "Set_Language_To_System_C");
   pragma Import (C, C_Set_UPER_Encoding, "Set_UPER_Encoding");
   pragma Import (C, C_Set_ACN_Encoding, "Set_ACN_Encoding");
   pragma Import (C, C_Set_Native_Encoding, "Set_Native_Encoding");
   pragma Import (C, C_Set_Sync_IF, "Set_Sync_IF");
   pragma Import (C, C_Set_ASync_IF, "Set_ASync_IF");
   pragma Import (C, C_Set_Unknown_IF, "Set_Unknown_IF");
   pragma Import (C, C_Set_Cyclic_IF, "Set_Cyclic_IF");
   pragma Import (C, C_Set_Sporadic_IF, "Set_Sporadic_IF");
   pragma Import (C, C_Set_Variator_IF, "Set_Variator_IF");
   pragma Import (C, C_Set_Protected_IF, "Set_Protected_IF");
   pragma Import (C, C_Set_Unprotected_IF, "Set_Unprotected_IF");
   pragma Import (C, C_Set_UndefinedKind_IF, "Set_UndefinedKind_IF");
   pragma Import (C, C_Set_Compute_Time, "Set_Compute_Time");
   pragma Import (C, C_Set_Period, "Set_Period");
   pragma Import (C, C_Set_Interface_Queue_Size, "Set_Interface_Queue_Size");
   pragma Import (C, C_Set_Context_Variable, "Set_Context_Variable");
   pragma Import (C, C_Set_Debug_Messages, "Set_Debug_Messages");
   pragma Import (C, C_Set_Zipfile, "Set_Zipfile");
   pragma Import (C, C_Set_ASN1_BasicType_Sequence,
                  "Set_ASN1_BasicType_Sequence");
   pragma Import (C, C_Set_ASN1_BasicType_SequenceOf,
                  "Set_ASN1_BasicType_SequenceOf");
   pragma Import (C, C_Set_ASN1_BasicType_Enumerated,
                  "Set_ASN1_BasicType_Enumerated");
   pragma Import (C, C_Set_ASN1_BasicType_Set,
                  "Set_ASN1_BasicType_Set");
   pragma Import (C, C_Set_ASN1_BasicType_SetOf,
                  "Set_ASN1_BasicType_SetOf");
   pragma Import (C, C_Set_ASN1_BasicType_Integer,
                  "Set_ASN1_BasicType_Integer");
   pragma Import (C, C_Set_ASN1_BasicType_Boolean,
                  "Set_ASN1_BasicType_Boolean");
   pragma Import (C, C_Add_Package,
                  "Add_Package");
   pragma Import (C, C_Set_ASN1_BasicType_Real, "Set_ASN1_BasicType_Real");
   pragma Import (C, C_Set_ASN1_BasicType_Choice, "Set_ASN1_BasicType_Choice");
   pragma Import (C, C_Set_ASN1_BasicType_String, "Set_ASN1_BasicType_String");
   pragma Import (C, C_Set_ASN1_BasicType_Unknown,
                  "Set_ASN1_BasicType_Unknown");
   pragma Import (C, C_Set_ASN1_BasicType_OctetString,
                  "Set_ASN1_BasicType_OctetString");

end Imported_Routines;
