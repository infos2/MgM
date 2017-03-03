/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2002-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#define PROGRAM 'CD Ejector'
#define VERSION ' version 1.2'
#define COPYRIGHT ' 2002-2011, Grigory Filatov'

#define NTRIM( n )  hb_ntos( n )

Static lEject := .T., lWinRun := .F., aCD := {}, lRelease := .F.

Function Main(lStartUp)
Local lSplash := FILE("MGLOGO.BMP")

	If ! Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		! Empty( GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "CD Ejector" ) )
		lWinRun := .T.
	EndIf

	SET MULTIPLE OFF

	SET GLOBAL HOTKEYS ON

	aCD := GetCDdrives()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON "OPEN" ;
		NOTIFYTOOLTIP PROGRAM + ": Left Click for open/close CD" ;
		ON NOTIFYCLICK MCIrun(.T.) ;
		ON RELEASE ( lRelease := .T., MCIrun() )

		Rmenu()

		// Define global hotkeys
		ON KEY CTRL+ALT+A ACTION MCIrun(.T.)
		ON KEY CTRL+ALT+E ACTION IF(lEject, MCIrun(.T.), )
		ON KEY CTRL+ALT+L ACTION IF(lEject, , MCIrun(.T.))

	END WINDOW

	Form_1.Auto_Run.Checked := lWinRun

   IF lSplash

	DEFINE WINDOW Form_Start ;
		AT 0, 0 ;
		WIDTH 160 HEIGHT 210 ;
		TOPMOST NOCAPTION ;
		ON INIT {|| SysWait(), DoMethod('Form_Start', 'Release') }

		@ -2, -2 IMAGE Image_1 ;
			PICTURE 'MGLOGO.BMP' ;
			WIDTH Form_Start.Width - 4  ;
			HEIGHT Form_Start.Height - 4 ;
			STRETCH

	END WINDOW

	CENTER WINDOW Form_Start

	ACTIVATE WINDOW Form_Start, Form_1

   ELSE

	ACTIVATE WINDOW Form_1

   ENDIF

Return Nil

*--------------------------------------------------------*
Procedure MCIrun( lNotifyClick )
*--------------------------------------------------------*
Local cBuffer := "", cItem, nItem := 1
Local AppHandle := Application.Handle

  default lNotifyClick := .F.

  IF Len(aCD) > 1 .AND. !lNotifyClick
	cItem := This.Name
	nItem := Val( SubStr( cItem, At("_", cItem) + 1 ) )
  ENDIF

  lEject := !lEject

  IF Len(aCD) == 1 .AND. !lNotifyClick .AND. lRelease
	mciSendString("STATUS CDAUDIO MEDIA PRESENT WAIT", @cBuffer, AppHandle)
	lEject := !( Upper(cBuffer) == 'TRUE' )
  ELSEIF lRelease
	RETURN
  ENDIF

  IF !lEject
	IF Len(aCD) > 1
		OpenThisCD( aCD[nItem] )
	ELSE
		mciSendString(Upper('SET CDAUDIO DOOR OPEN WAIT'), @cBuffer, AppHandle)
	ENDIF
  ELSE
	IF Len(aCD) > 1
		CloseThisCD( aCD[nItem] )
	ELSE
		mciSendString(Upper('SET CDAUDIO DOOR CLOSED WAIT'), @cBuffer, AppHandle)
	ENDIF
  ENDIF

  Rmenu()
  Form_1.NotifyTooltip := IF( lEject, "Open ", "Close " ) + "CD"
  Form_1.NotifyIcon := IF( lEject, "OPEN", "CLOSE")

RETURN
 
*--------------------------------------------------------*
Procedure Rmenu()
*--------------------------------------------------------*
Local i, cName

	DEFINE NOTIFY MENU OF Form_1
		ITEM 'Auto&Run'	ACTION {|| lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) } ;
				NAME Auto_Run
		SEPARATOR
		IF Len(aCD) > 1
			For i := 1 To Len( aCD )
				cName := "CD_" + NTRIM( i )
				ITEM "Open/Close " + aCD[i] ACTION MCIrun() NAME &cName
			Next
		ELSE
			ITEM IF( lEject, "&Open ", "&Close " ) + "CD" ACTION MCIrun()
		ENDIF
		SEPARATOR
		ITEM 'Removable Drives List' ACTION {|| MsgInfo( GetRemovableDrives() ) } NAME Removables
		SEPARATOR
		ITEM '&About...' ACTION ShellAbout( "About " + PROGRAM + "#", ;
				PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "AMAIN") )
		SEPARATOR	
		ITEM 'E&xit'	ACTION Form_1.Release
	END MENU

	IF Len(aCD) == 1
		_DefaultMenuItem( 3, "Auto_Run", "Form_1" )
	ENDIF

Return

#define DRIVE_CDROM       5
*--------------------------------------------------------*
function GetCDdrives()
*--------------------------------------------------------*
local aDrives := {}, aAllDrv := GetDrives(), i

For i := 1 To Len( aAllDrv )
   if GetDriveType( aAllDrv[i] ) == DRIVE_CDROM
      AAdd( aDrives, aAllDrv[i] )
   endif
Next

return aDrives

#define DRIVE_REMOVABLE    2
*--------------------------------------------------------*
function GetRemovableDrives()
*--------------------------------------------------------*
local aDrives := {}, aAllDrv := GetDrives(), i

For i := 1 To Len( aAllDrv )
   if GetDriveType( aAllDrv[i] ) == DRIVE_REMOVABLE
      AAdd( aDrives, aAllDrv[i] )
   endif
Next

return aDrives

*--------------------------------------------------------*
Procedure SysWait(nWait)
*--------------------------------------------------------*
Local iTime := Seconds()

DEFAULT nWait TO 2

Do While Seconds() - iTime < nWait
	INKEY(.5)
	DoEvents()
EndDo

Return

*--------------------------------------------------------*
Static Function WinRun(lMode)
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "CD Ejector" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "CD Ejector", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "CD Ejector" )
   ENDIF

return NIL

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := Iif( nKey == NIL, HKEY_CURRENT_USER, nKey )
   uValue := Iif( uValue == NIL, "", uValue )
   oReg := TReg32():Create( nKey, cRegKey )
   cValue := oReg:Get( cSubKey, uValue )
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
STATIC FUNCTION SETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

RETURN nValue

*--------------------------------------------------------*
Function _DefaultMenuItem( ItemNumber, ItemName, FormName )
*--------------------------------------------------------*
Local i , h

	i := GetControlIndex( ItemName, FormName )

	h := _HMG_aControlpageMap[ i ]

	SetMenuDefaultItem( h, ItemNumber )

Return Nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbstack.h"
#include "hbapiitm.h"

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#endif

void CloseOrEjectCD(const char *NameDriveCD, BOOL FlagOpenClose)
{
	MCI_OPEN_PARMS OpenParm;
	DWORD DeviceID;
	MCIERROR status;
	CHAR bufErr[255];
	DWORD Flags;

	OpenParm.dwCallback = 0;
	OpenParm.lpstrDeviceType = "CDAudio";
	OpenParm.lpstrElementName = NameDriveCD; 
	Flags = MCI_OPEN_TYPE | MCI_OPEN_ELEMENT;

	mciSendCommand(0, MCI_OPEN, Flags, (LONG) &OpenParm);
	DeviceID = OpenParm.wDeviceID;

	status = mciSendCommand(DeviceID, MCI_SET, (FlagOpenClose) ? MCI_SET_DOOR_OPEN : MCI_SET_DOOR_CLOSED, NULL);

	if(status)
	{
		mciGetErrorString(status, bufErr, 254);
		MessageBox(NULL, bufErr, "Error", MB_OK + MB_ICONSTOP);
	}
 
	mciSendCommand(DeviceID, MCI_CLOSE, MCI_WAIT, NULL);
}

HB_FUNC ( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeSystemEnvironmentPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC ( MCISENDSTRING )

{
	BYTE bBuffer[ 255 ];

	hb_retnl( ( LONG ) mciSendString( ( LPSTR) hb_parc( 1 ), ( LPSTR ) bBuffer, 254, ( HWND ) hb_parnl( 3 ) ) );

	hb_storc( bBuffer, 2 );
}

HB_FUNC ( SETMENUDEFAULTITEM )
{
	SetMenuDefaultItem( (HMENU) hb_parnl( 1 ), hb_parni( 2 ) - 1, TRUE );
}

HB_FUNC ( GETDRIVES )
{
	DWORD dwDrives=GetLogicalDrives();
	DWORD dwMask=1;
	DWORD dwCount=0, i;
	char szPath[4]="A:\\";

	for(i=0;i<27;i++)
	{
		if (dwDrives&dwMask) dwCount++;
		dwMask<<=1;
	}

	hb_reta(dwCount);

	dwCount=0;
	dwMask=1;
	szPath[3]=0;

	for(i=0;i<27;i++)
	{
		if (dwDrives&dwMask)
		{
			szPath[0]='A'+i;
			HB_STORC(szPath,-1,++dwCount);
		}
		dwMask<<=1;
	}
}

HB_FUNC ( GETDRIVETYPE )
{
	hb_retni( GetDriveType( (LPCTSTR) hb_parc(1) ) ) ;
}

HB_FUNC ( OPENTHISCD )
{
	CloseOrEjectCD( hb_parc( 1 ), TRUE );
}

HB_FUNC ( CLOSETHISCD )
{
	CloseOrEjectCD( hb_parc( 1 ), FALSE );
}
/* 
HB_FUNC ( INITIMAGE )
{
	HWND  h;
	HBITMAP hBitmap;
	HWND hwnd;

	hwnd = (HWND) hb_parnl(1);

	h = CreateWindowEx(0,"static",NULL, WS_CHILD | WS_VISIBLE | SS_BITMAP | SS_NOTIFY,
		hb_parni(3), hb_parni(4), 0, 0, hwnd, (HMENU)hb_parni(2), GetModuleHandle(NULL), NULL );

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL), hb_parc(5), IMAGE_BITMAP, hb_parni(6), hb_parni(7), LR_CREATEDIBSECTION);
	}

	SendMessage( h, (UINT)STM_SETIMAGE, (WPARAM)IMAGE_BITMAP, (LPARAM)hBitmap );

	hb_retnl( (LONG) h );
}

HB_FUNC ( C_SETPICTURE )
{
	HBITMAP hBitmap;

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_CREATEDIBSECTION);
	}

	SendMessage((HWND) hb_parnl (1),(UINT)STM_SETIMAGE,(WPARAM)IMAGE_BITMAP,(LPARAM)hBitmap);

	hb_retnl ( (LONG) hBitmap );
}
 */
#pragma ENDDUMP
