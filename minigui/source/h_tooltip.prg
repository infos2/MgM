/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2017, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

/* P.Ch. 16.10. */

#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include "minigui.ch"

#ifdef HMG_LEGACY_OFF // For compatibility with old version only. Can be removed in future. 
   #undef  HMG_LEGACY_OFF
   #define _LEGACY_OFF
#endif

#ifndef HMG_LEGACY_OFF
FUNCTION _SetToolTipMaxWidth ( nNewMaxWidth )
   RETURN _SetGetToolTipMaxWidth ( nNewMaxWidth )

FUNCTION _SetToolTipBalloon ( lNewBalloon )
   RETURN _SetGetToolTipBalloonOnOff ( lNewBalloon )

FUNCTION _lSetToolTip( lNewValue )
   RETURN _SetGetToolTipOnOff( lNewValue )
#endif

#ifdef _LEGACY_OFF
   #undef  _LEGACY_OFF
   #define HMG_LEGACY_OFF
#endif

*-----------------------------------------------------------------------------*
FUNCTION _SetGetToolTipMaxWidth ( nNewMaxWidth )
*-----------------------------------------------------------------------------*
   STATIC nMaxWidth := -1
   LOCAL nOldMaxWidth := nMaxWidth

   IF ISNUMERIC( nNewMaxWidth )
      nMaxWidth := nNewMaxWidth
   ENDIF

RETURN nOldMaxWidth

*-----------------------------------------------------------------------------*
FUNCTION _SetGetToolTipBalloonOnOff ( lNewBalloon )
*-----------------------------------------------------------------------------*
   STATIC lBalloon := .F.
   LOCAL lOldBalloon := lBalloon

   IF ISLOGICAL( lNewBalloon )
      lBalloon := lNewBalloon
   ENDIF

RETURN lOldBalloon

*-----------------------------------------------------------------------------*
FUNCTION _SetGetToolTipOnOff( lNewValue )
*-----------------------------------------------------------------------------*
   STATIC lToolTip := .T.
   LOCAL lOldValue := lToolTip

   IF ISLOGICAL( lNewValue )
      lToolTip := lNewValue
   ENDIF

RETURN lOldValue
