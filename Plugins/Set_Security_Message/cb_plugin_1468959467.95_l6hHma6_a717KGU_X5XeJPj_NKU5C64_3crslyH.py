#!/bin/env python

from utilities.models import GlobalPreferences
from portals.models import PortalConfig

def run(**kwargs):
    # set the security message
    gp = GlobalPreferences.get()
    gp.security_message = "{{ message }}"
    gp.save()
    
    # set its background color
    default_portal = PortalConfig.get_current_portal()
    default_portal.security_bg_color = "{{ message_background_color_code }}"
    default_portal.save()
    
    return "", "", ""