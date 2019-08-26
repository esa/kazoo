/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "thermal_manager.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void thermal_manager_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void thermal_manager_PI_heaterOn(const asn1SccT_Boolean *IN_override)
{
    // Heater override called, send message to GUI
    
    thermal_manager_RI_GUIupdateHeaterOverride(IN_override);
}

