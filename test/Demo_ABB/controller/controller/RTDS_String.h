#include <string.h>
#include <stdlib.h>

#ifndef _RTDS_STRING_H_
#define _RTDS_STRING_H_

#ifdef __cplusplus
extern "C" {
#endif

/* Maximum length for a string in SDL-RT projects converted from SDL (setup by translator) */
#ifndef RTDS_MAX_STRING
#define RTDS_MAX_STRING 256
#endif

/* Maximum length for a bitstring in TTCN-3 */
#ifndef RTDS_BITSTRING_MAX_SIZE
#define RTDS_BITSTRING_MAX_SIZE 64
#endif

/* Maximum length for a octetstring in TTCN-3 */
#ifndef RTDS_OCTETSTRING_MAX_SIZE
#define RTDS_OCTETSTRING_MAX_SIZE 256
#endif

/* Type for strings in SDL-RT projects converted from SDL */
typedef char RTDS_String[RTDS_MAX_STRING];

/* Type for octet strings in SDL-RT projects converted from SDL */
typedef struct _RTDS_OctetString
  {
  unsigned char __string[RTDS_OCTETSTRING_MAX_SIZE];
  unsigned int  __length;
  } RTDS_OctetString;

/* Type for bit strings in SDL-RT projects converted from SDL */
typedef struct _RTDS_BitString
  {
  unsigned char __string[RTDS_BITSTRING_MAX_SIZE];
  unsigned int  __length;
  } RTDS_BitString;
  
/* Function RTDS_StringAssign: used in assignment translations (string := string) */
extern void RTDS_StringAssign(RTDS_String sDest, RTDS_String sSource);

/* Function RTDS_StringCat: used for string concatenation (string // string) */
/* first param is a temporary string for the result */
extern char * RTDS_StringCat(RTDS_String sDest, RTDS_String s1, RTDS_String s2);

/* Function RTDS_MkString: creates a string from a character */
/* first param is a temporary string for the result */
extern char * RTDS_MkString(RTDS_String sDest, char c);

/* Function RTDS_StringLast: returns the last character in a string */
extern char RTDS_StringLast(RTDS_String s);

/* Function RTDS_SubString: extracts a sub-string from a string - startIndex starts at 1 */
/* first param is a temporary string for the result */
extern char * RTDS_SubString(RTDS_String sDest, RTDS_String s, int startIndex, int length);

/* Function RTDS_StringExtract: extract a given character from a string and return the resulting string */
/* first param is a temporary string for the result */
extern char * RTDS_StringExtract(RTDS_String sDest, RTDS_String s, int charIndex);

/* Function RTDS_StringModify: replaces a given character in a string and return the resulting string */
/* first param is a temporary string for the result */
extern char * RTDS_StringModify(RTDS_String sDest, RTDS_String s, int charIndex, char charRepl);

/* Function RTDS_StringReplace: Replaces a portion of a string by another one */
/* first param is a temporary string for the result */
char * RTDS_StringReplace(RTDS_String sDest, RTDS_String s, int index, int length, RTDS_String replacement);

/* Macro RTDS_BIN_STRING_CAT: generic macro for binary string concatenation */
#define RTDS_BIN_STRING_CAT(RESULT_VAR, BIN_STRING1, BIN_STRING2) \
  RTDS_BinStringCat(&(RESULT_VAR), &((RESULT_VAR).__length), (BIN_STRING1).__length, (BIN_STRING2).__length, \
                    &((RESULT_VAR).__string[0]), &((BIN_STRING1).__string[0]), &((BIN_STRING2).__string[0]))

/*
** FUNCTION RTDS_BinStringCat:
** ---------------------------
** Generic function concatenating 2 binary strings, whatever their actual type is. Stores the result
** in its first parameter and returns it.
*/
void * RTDS_BinStringCat(
  void          * result_var,         /* Result variable */
  unsigned int  * p_result_length,    /* Pointer on the length for the result string */
  long            bin_string1_length, /* Length for the first string to concatenate */
  long            bin_string2_length, /* Length for the second string to concatenate */
  unsigned char * result_buffer,      /* Buffer where the actual contents of the result binary string is stored */
  unsigned char * bin_string1_buffer, /* Buffer where the actual contents of the first binary string to concatenate is stored */
  unsigned char * bin_string2_buffer  /* Buffer where the actual contents of the second binary string to concatenate is stored */
);

/* Macro RTDS_OCTET_STRING_CAT: generic macro for octet string concatenation */
#define RTDS_OCTET_STRING_CAT(RESULT_VAR, OCTET_STRING1, OCTET_STRING2) \
  RTDS_OctetStringCat(&(RESULT_VAR), &((RESULT_VAR).__length), (OCTET_STRING1).__length, (OCTET_STRING2).__length, \
                      &((RESULT_VAR).__string[0]), &((OCTET_STRING1).__string[0]), &((OCTET_STRING2).__string[0]))

/*
** FUNCTION RTDS_OctetStringCat:
** -----------------------------
** Generic function concatenating 2 octet strings, whatever their actual type is. Stores the result
** in its first parameter and returns it.
*/
void * RTDS_OctetStringCat(
  void          * result_var,           /* Result variable */
  unsigned int  * p_result_length,      /* Pointer on the length for the result string */
  unsigned int    octet_string1_length, /* Length for the first string to concatenate */
  unsigned int    octet_string2_length, /* Length for the second string to concatenate */
  unsigned char * result_buffer,        /* Buffer where the actual contents of the result octet string is stored */
  unsigned char * octet_string1_buffer, /* Buffer where the actual contents of the first octet string to concatenate is stored */
  unsigned char * octet_string2_buffer  /* Buffer where the actual contents of the second octet string to concatenate is stored */
);

/* Macro RTDS_BIN_OCTET_STRING_CMP: compares 2 binary or octet strings */
#define RTDS_BIN_OCTET_STRING_CMP(STRING_VAR1, STRING_VAR2, DIV) \
  memcmp((STRING_VAR1).__string, (STRING_VAR2).__string, ((((STRING_VAR1).__length > (STRING_VAR2).__length)?((STRING_VAR1).__length):((STRING_VAR2).__length)) + DIV - 1) / DIV)
                    
                    
/* Macro RTDS_SEQUENCE_CONCAT: generic macro concatenating 2 sequences; first param is a temporary variable for the result */
#define RTDS_SEQUENCE_CONCAT(RESULT_VAR, SEQUENCE_VAR1, SEQUENCE_VAR2) \
  RTDS_sequenceConcat(&(RESULT_VAR), &((RESULT_VAR).length), (SEQUENCE_VAR1).length, (SEQUENCE_VAR2).length, \
                      (unsigned char*)&((RESULT_VAR).elements), (unsigned char*)&((SEQUENCE_VAR1).elements), (unsigned char*)&((SEQUENCE_VAR2).elements), \
                      sizeof((RESULT_VAR).elements[0]))

/*
** FUNCTION RTDS_sequenceConcat:
** -----------------------------
** Generic function concatenating 2 sequences. Stores the result in its first parameter and returns it.
*/
void * RTDS_sequenceConcat(
  void          * result_var,             /* Pointer of the result variable */
  unsigned int  * result_length,          /* Pointer on the length field in the result variable */
  unsigned int    var1_length,            /* Length of the first sequence to concatenate */
  unsigned int    var2_length,            /* Length of the second sequence to concatenate */
  unsigned char * result_elements,        /* Pointer on the elements array for the result variable */
  unsigned char * sequence_var1_elements, /* Pointer on the elements array for the first sequence to concatenate */
  unsigned char * sequence_var2_elements, /* Pointer on the elements array for the second sequence to concatenate */
  unsigned int    element_size            /* Size for an element in both sequences, in bytes */
);

#ifdef __cplusplus
}
#endif

#endif


