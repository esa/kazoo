#include <stdlib.h>
#include <string.h>

#include "RTDS_String.h"


/*
 * FUNCTION safe_strcpy:
 * ---------------------
 * Copies a string to another with a maximum number of copied character.
 * Different from strncpy because it never copies more than the length of
 * the copied string. The destination string is also always terminated with
 * a \0 whatever happens.
 *  - sDest: Destination string.
 *  - sSource: Source string.
 *  - maxChars: Maximum characters that should end up in destination string.
 *              Since the ending \0 is always copied, that means that at most
 *              maxChars - 1 are copied from the source string.
 * Returns the pointer on the last copied character in destination string (the \0).
 */
static char * safe_strcpy(char * sDest, char * sSource, unsigned int maxChars)
{
  unsigned int i = 0;
  if ( maxChars > 1)
  {
    while ( *sSource != '\0' )
    {
      *sDest = *sSource;
      sDest++; sSource++; i++;
      if ( i >= maxChars - 1 ) break;
    }
  }
  *sDest = '\0';
  return sDest;
}


/*
 * FUNCTION RTDS_StringAssign:
 * ---------------------------
 * Assigns a string to another; used to translate SDL
 * string assignments (string := string)
 * Parameters:
 * - sDest: destination string
 * - sSource: source string
 */

void RTDS_StringAssign(RTDS_String sDest, RTDS_String sSource)
{
  /* Copy source into destination, taking care of buffer overruns */
  safe_strcpy(sDest, sSource, RTDS_MAX_STRING);
}


/*
 * FUNCTION RTDS_StringCat:
 * ------------------------
 * Concatenates a string to another and puts the result in a third one;
 * used to translate SDL string concatenation operator (string // string)
 * Parameters:
 * - sDest: destination string
 * - s1, s2: the strings to concatenate
 * Returns: sDest
 */

char * RTDS_StringCat(RTDS_String sDest, RTDS_String s1, RTDS_String s2)
{
  char * p;
  /* Copy first string into destination, taking care of buffer overruns */
  p = safe_strcpy(sDest, s1, RTDS_MAX_STRING);
  /* Concatenate second string, taking care of buffer overruns */
  safe_strcpy(p, s2, RTDS_MAX_STRING - (p - sDest));
  /* Return destination string */
  return sDest;
}


/*
 * FUNCTION RTDS_MkString:
 * -----------------------
 * Creates a string from a character
 * Parameters:
 * - sDest: destination string
 * - c: the character
 * Returns: sDest
 */

char * RTDS_MkString(RTDS_String sDest, char c)
{
  sDest[0] = c;
  sDest[1] = '\0';
  return sDest;
}


/*
 * FUNCTION RTDS_StringLast:
 * ------------------------
 * Returns the last character is a string
 * Parameter:
 * - s: the string
 * Returns: its last character
 */

char RTDS_StringLast(RTDS_String s)
{
  return s[strlen(s) - 1];
}


/*
 * FUNCTION RTDS_SubString:
 * ------------------------
 * Returns a sub-string of a given string
 * Parameters:
 * - sDest: destination string
 * - s: the string from which the sub-string must be extracted
 * - startIndex: the index of the first character in the sub-string, starting at 1
 * - length: the length of the sub-string to extract
 * Returns: sDest
 */

char * RTDS_SubString(RTDS_String sDest, RTDS_String s, int startIndex, int length)
{
  /* Make sure extracted string won't be too long */
  if ( length >= RTDS_MAX_STRING - 1 )
    length = RTDS_MAX_STRING - 1;
  /* Extract sub-string to destination - NB: add 1 to the copied length for the \0 */
  safe_strcpy(sDest, &(s[startIndex - 1]), length + 1);
  /* Return result string */
  return sDest;
}


/*
 * FUNCTION RTDS_StringExtract:
 * ----------------------------
 * Removes a character from a string and returns the result
 * Parameters:
 * - sDest: destination string
 * - s: the string from which the character should be removed
 * - charIndex: the index of the character to remove, starting at 1
 * Returns: sDest
 */

char * RTDS_StringExtract(RTDS_String sDest, RTDS_String s, int charIndex)
{
  int i = 0, j = 0;
  
  while ( s[i] != '\0' && j < RTDS_MAX_STRING - 1 )
  {
    if ( i != charIndex - 1 )
    {
      sDest[j] = s[i];
      j++;
    }
    i++;
  }
  sDest[j] = '\0';
  return sDest;
}


/*
 * FUNCTION RTDS_StringModify:
 * ---------------------------
 * Sets a string to another one with a character at a given index replaced by another one.
 * Parameters:
 * - sDest: destination string
 * - s: source string, where the character must be replaced
 * - charIndex: index of the characters to replace in s, starting at 1 (*NOT* 0!)
 * - charRepl: replacement character
 * Returns: sDest
 */

char * RTDS_StringModify(RTDS_String sDest, RTDS_String s, int charIndex, char charRepl)
{
  /* Copy source into destination, taking care of buffer overruns */
  safe_strcpy(sDest, s, RTDS_MAX_STRING);
  /* Replace character at specified index */
  sDest[charIndex - 1] = charRepl;
  /* Return destination string */
  return sDest;
}


/*
 * FUNCTION RTDS_StringReplace:
 * ----------------------------
 * Replaces a portion of a string by another one and puts the result in a thrid one. The replaced
 * portion is given by its first index and its length.
 * Parameters:
 * - sDest: destination string
 * - s: source string, where the portion must be replaced
 * - index: index of the first character in the portion to replace, starting at 1 (*NOT* 0!)
 * - length: length of the portion to replace
 * - replacement: replacement string for the portion
 * Returns: sDest
 */

char * RTDS_StringReplace(RTDS_String sDest, RTDS_String s, int index, int length, RTDS_String replacement)
{
  char  * end_pointer;
  int     replacement_length;
  
  /* Copy portion of original string before replaced portion. Index starts at 1, so should be index - 1,
     but should add 1 for the ending \0 too... */
  end_pointer = safe_strcpy(sDest, &(s[0]), index);
  /* Copy replacement string with its ending \0 */
  replacement_length = strlen(replacement);
  end_pointer = safe_strcpy(end_pointer, &(replacement[0]), replacement_length + 1);
  /* Copy portion of original string after replaced portion. */
  safe_strcpy(end_pointer, &(s[index - 1 + length]), RTDS_MAX_STRING - index - replacement_length - 1);
  return sDest;
}


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
)
  {
  unsigned int  i = 0, j = 0;
  unsigned char left_shift, right_shift, low_mask, high_mask;
  unsigned char previous_byte, new_byte;
  
  /* Update result length */
  *p_result_length = bin_string1_length + bin_string2_length;
  /* Copy full bytes in first string to result */
  while ( bin_string1_length >= 8 )
    {
    result_buffer[i] = bin_string1_buffer[i];
    i++;
    bin_string1_length -= 8;
    }
  /* For the next steps in the concatenation, we need to concatenate bits, and not bytes. So there is a few bits left
  ** in the first string, like:
  ** 10010000
  ** <--->
  ** If the next byte is 01101110 for example, the next byte in the concatenation will be:
  ** 10010011
  ** <-1-><2>
  ** with 1 being the bits left from the previous step, and 2 the added bits from the high bits in the new byte. The
  ** bits left in the new byte (---01110) in the example) have to be shift left and can then be used in the next step.
  ** So we need:
  **  - A mask for the bits to keep in the new byte (11100000 in the example)
  **  - By how many bits these bits must be shifted right before being added to the previous byte (5 in the example)
  **  - Once it's done, the mask for the bits left in the new byte (00011111 in the example).
  **  - By how many bits what's left must be shifted left to become the new previous byte (3 in the example).
  ** This second figure is the number of bits left in the first string to concatenate.
  */
  right_shift = bin_string1_length;
  left_shift = 8 - right_shift;
  low_mask = (1 << right_shift) - 1;
  high_mask = 0xFF - low_mask;
  if ( bin_string1_length == 0 )
    previous_byte = 0;
  else
    previous_byte = bin_string1_buffer[i];
  while ( bin_string2_length > 0 )
    {
    result_buffer[i] = previous_byte + ((bin_string2_buffer[j] & high_mask) >> right_shift);
    previous_byte = (bin_string2_buffer[j] & low_mask) << left_shift;
    i++; j++;
    bin_string2_length -= 8;
    }
  result_buffer[i] = previous_byte;
  /* Return result variable */
  return result_var;
  }


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
)
  {
  int i = 0, j = 0;
  *p_result_length = octet_string1_length + octet_string2_length;
  while ( octet_string1_length > 0 )
    {
    result_buffer[i] = octet_string1_buffer[i];
    i++; octet_string1_length--;
    }
  while ( octet_string2_length > 0 )
    {
    result_buffer[i] = octet_string2_buffer[j];
    i++; j++; octet_string2_length--;
    }
  return result_var;
  }


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
)
  {
  unsigned int i1, i2;
  
  /* Store result length */
  *result_length = var1_length + var2_length;
  /* Concatenate elements */
  while ( var1_length != 0 )
    {
    memcpy(result_elements, sequence_var1_elements, element_size);
    result_elements += element_size;
    sequence_var1_elements += element_size;
    var1_length --;
    }
  while ( var2_length != 0 )
    {
    memcpy(result_elements, sequence_var2_elements, element_size);
    result_elements += element_size;
    sequence_var2_elements += element_size;
    var2_length --;
    }
  /* Returns return variable */
  return result_var;
  }


