
/* Private types for param service  */

#ifndef __USER_CODE_H_param_service_private__
#define ___USER_CODE_H_param_service_private__

typedef struct parameterIdentifier
{
    int   objectId;
    char* descriptionStr;
} ParameterIdentifier;

typedef struct parameterDefinition
{
    int   objectId;
    // short form mal type
    unsigned char paramType;
    ParameterIdentifier *pIdentifier;  
} ParameterDefinition;

typedef struct parameterValue
{
    int   objectId;
    ParameterDefinition *pDefinition;
    char *pBuffer;
    size_t bufferLen; 
} ParameterValue;


#endif
