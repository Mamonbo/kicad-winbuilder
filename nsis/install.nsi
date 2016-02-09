; Installation script for KiCad generated by Alastair Hoyle
;
; This installation script requires NSIS (Nullsoft Scriptable Install System)
; version 3.x http://nsis.sourceforge.net/Main_Page
;
; This script is provided as is with no warranties.
;
; Copyright (C) 2006 Alastair Hoyle <ahoyle@hoylesolutions.co.uk>
; Copyright (C) 2015 Nick Østergaard
; Copyright (C) 2015 Brian Sidebotham <brian.sidebotham@gmail.com>
; Copyright (C) 2016 Bevan Weiss <bevan.weiss@gmail.com>
;
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the Free
; Software Foundation. This program is distributed in the hope that it will be
; useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
; Public License for more details.
;
; This script should be in a subdirectory of the full build directory
; (Kicad/NSIS by default). When the build is updated the product and installer
; versions should be updated before recompiling the installation file
;
; This script expects the install.ico, uninstall.ico, language and license
; files to be in the same directory as this script

!include "winmessages.nsh"

; General Product Description Definitions
!define PRODUCT_NAME "KiCad"
!define LIBRARIES_WEB_SITE "https://github.com/KiCad/"
!define KICAD_MAIN_SITE "www.kicad-pcb.org/"
!define COMPANY_NAME ""
!define TRADE_MARKS ""
!define COPYRIGHT "Kicad Developers Team"
!define COMMENTS ""
!define HELP_WEB_SITE "http://groups.yahoo.com/group/kicad-users/"
!define DEVEL_WEB_SITE "https://launchpad.net/kicad/"
!define WINGS3D_WEB_SITE "http://www.wings3d.com"

!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define UNINST_ROOT "HKLM"

!define ENV_HKLM 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'

!define gflag ;Needed to use ifdef and such
;Define on command line //DPRODUCT_VERSION=42
!ifndef PRODUCT_VERSION
  !define PRODUCT_VERSION "unknown"
!endif

!ifndef OPTION_STRING
  !define OPTION_STRING "unknown"
!endif

;Comment out the following SetCompressor command while testing this script
;SetCompressor /final /solid lzma

CRCCheck force
;XPStyle on
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

!ifndef OUTFILE
  !define OUTFILE "kicad-product-${PRODUCT_VERSION}-${OPTION_STRING}.exe"
!endif
OutFile ${OUTFILE}

; Request that we are executed as admin rights so we can install into
; PROGRAMFILES without ending up in the virtual store
RequestExecutionLevel admin

!if ${ARCH} == 'x86_64'
  InstallDir "$PROGRAMFILES64\KiCad"
!else
  InstallDir "$PROGRAMFILES\KiCad"
!endif

ShowInstDetails show
ShowUnInstDetails show
BrandingText "KiCad installer for windows"

; MUI 2 compatible ------
!include "MUI2.nsh"
!include "${NSISDIR}\Examples\System\System.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "install.ico"
!define MUI_UNICON "uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "kicad-header.bmp" ; optional
!define MUI_WELCOMEFINISHPAGE_BITMAP "kicad-welcome.bmp"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${UNINST_ROOT}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Installer pages
!define MUI_CUSTOMFUNCTION_GUIINIT myGuiInit
!define MUI_CUSTOMFUNCTION_UNGUIINIT un.myGuiInit
!define MUI_WELCOMEPAGE_TEXT $(WELCOME_PAGE_TEXT)
!insertmacro MUI_PAGE_WELCOME
;!insertmacro MUI_PAGE_LICENSE $(MUILicense)
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_SHOWREADME ${WINGS3D_WEB_SITE}
!define MUI_FINISHPAGE_SHOWREADME_TEXT $(WINGS3D_PROMPT)
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_PAGE_CUSTOMFUNCTION_SHOW ModifyFinishPage
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
; - To add another language; add an insert macro line here and include a language file as below
; - This must be after all page macros have been inserted
!insertmacro MUI_LANGUAGE "English" ;first language is the default language
;!insertmacro MUI_LANGUAGE "French"
;!insertmacro MUI_LANGUAGE "Italian"
;!insertmacro MUI_LANGUAGE "Polish"
;!insertmacro MUI_LANGUAGE "Portuguese"
;!insertmacro MUI_LANGUAGE "Dutch"
;!insertmacro MUI_LANGUAGE "Russian"
;!insertmacro MUI_LANGUAGE "Japanese"

!include "English.nsh"
;!include "German.nsh"
;!include "Spanish.nsh"
;!include "French.nsh"
;!include "Italian.nsh"
;!include "Japanese.nsh"
;!include "Dutch.nsh"
;!include "Polish.nsh"

;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL

; MUI end ------

Function .onInit
  ; Request that we get elevated rights to install so that we don't end up in
  ; the virtual store
  ClearErrors
  UserInfo::GetName
  IfErrors Win9x
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  UserInfo::GetOriginalAccountType
  Pop $2
  StrCmp $1 "Admin" 0 AdminQuit
    Goto LangDisplay
  
  AdminQuit:
    MessageBox MB_OK $(ERROR_ADMIN_REQ)
    Quit

  LangDisplay:    
    ReserveFile "install.ico"
    ReserveFile "uninstall.ico"
    ReserveFile "${NSISDIR}\Plugins\x86-unicode\LangDLL.dll"
    ReserveFile "${NSISDIR}\Plugins\x86-unicode\System.dll"
    !insertmacro MUI_LANGDLL_DISPLAY
    Goto done

  Win9x:
    MessageBox MB_OK $(ERROR_WIN9X)
    Quit

  done:
FunctionEnd

Function myGuiInit
  Call PreventMultiInstances
  Call CheckAlreadyInstalled
FunctionEnd

Function ModifyFinishPage
  ; resize the Text control, otherwise we get clipping on the top and bottom
  ; Create RECT struct
  System::Call "*${stRECT} .r1"
  ; Find Window info for the window we're displaying
  System::Call "User32::GetWindowRect(i, i) i ($mui.FinishPage.ShowReadme, r1) .r2"
  ; Get left/top/right/bottom
  System::Call "*$1${stRECT} (.r2, .r3, .r4, .r5)"
  System::Free $1
  ; calculate the width, we'll keep this the same
  IntOp $6 $4 - $2
  ; then calculate the height, and we'll make this 4 times as high
  IntOp $7 $5 - $3
  IntOp $7 4 * $7
  ; then we finally update the control size.. we don't want to move it, or change its z-order however
  System::Call "User32::SetWindowPos(i $mui.FinishPage.ShowReadme, i 0, i 0, i 0, i $6, i $7, i ${SWP_NOMOVE} | ${SWP_NOZORDER})"
FunctionEnd

Section $(TITLE_SEC_MAIN) SEC01
  SectionIn RO
  SetOverwrite try
  SetOutPath "$INSTDIR"
  File /nonfatal "..\AUTHORS.txt"
  File /nonfatal "..\COPYRIGHT.txt"
  File /nonfatal "..\license_for_documentation.txt"
  SetOutPath "$INSTDIR\share\kicad\template"
  File /nonfatal /r "..\share\kicad\template\*"
  SetOutPath "$INSTDIR\bin"
  File /r "..\bin\*"
  SetOutPath "$INSTDIR\lib"
  File /r "..\lib\*"
  SetOutPath "$INSTDIR\share\kicad\internat"
  File /nonfatal /r "..\share\kicad\internat\*"
  SetOutPath "$INSTDIR\ssl\certs"
  File "..\ssl\certs\ca-bundle.crt"
SectionEnd

Section $(TITLE_SEC_SCHLIB) SEC02
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\library"
  File /nonfatal /r "..\share\kicad\library\*"
SectionEnd

Section $(TITLE_SEC_FPLIB) SEC03
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\modules"
  File /nonfatal /r "..\share\kicad\modules\*"
SectionEnd

Section $(TITLE_SEC_FPWIZ) SEC04
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\scripting\plugins"
  File /nonfatal /r "..\share\kicad\scripting\plugins\*"
SectionEnd

Section $(TITLE_SEC_DEMOS) SEC05
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\demos"
  File /nonfatal /r "..\share\kicad\demos\*"
  SetOutPath "$INSTDIR\share\doc\kicad\tutorials"
  File /nonfatal /r "..\share\doc\kicad\tutorials\*"
SectionEnd

SectionGroup $(TITLE_SEC_DOCS) SEC06
  Section $(LANGUAGE_NAME_EN) SEC06_EN
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\en"
    File /nonfatal /r "..\share\doc\kicad\help\en\*"
  SectionEnd
  Section $(LANGUAGE_NAME_DE) SEC06_DE
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\de"
    File /nonfatal /r "..\share\doc\kicad\help\de\*"
  SectionEnd
  Section $(LANGUAGE_NAME_ES) SEC06_ES
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\es"
    File /nonfatal /r "..\share\doc\kicad\help\es\*"
  SectionEnd
  Section $(LANGUAGE_NAME_FR) SEC06_FR
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\fr"
    File /nonfatal /r "..\share\doc\kicad\help\fr\*"
  SectionEnd
  Section $(LANGUAGE_NAME_IT) SEC06_IT
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\it"
    File /nonfatal /r "..\share\doc\kicad\help\it\*"
  SectionEnd
  Section $(LANGUAGE_NAME_JA) SEC06_JA
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\ja"
    File /nonfatal /r "..\share\doc\kicad\help\ja\*"
  SectionEnd
  Section $(LANGUAGE_NAME_NL) SEC06_NL
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\nl"
    File /nonfatal /r "..\share\doc\kicad\help\nl\*"
  SectionEnd
  Section $(LANGUAGE_NAME_PL) SEC06_PL
    SetOverwrite try
    SetOutPath "$INSTDIR\share\doc\kicad\help\pl"
    File /nonfatal /r "..\share\doc\kicad\help\pl\*"
  SectionEnd
SectionGroupEnd

Section $(TITLE_SEC_ENV) SEC07
  WriteRegExpandStr ${ENV_HKLM} KICAD_PTEMPLATES "$INSTDIR\share\kicad\template"
  WriteRegExpandStr ${ENV_HKLM} KISYS3DMOD "$INSTDIR\share\kicad\modules\packages3d"
  WriteRegExpandStr ${ENV_HKLM} KISYSMOD "$INSTDIR\share\kicad\modules"
  
  WriteRegDWORD ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "EnvInstalled" "1"
  
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

Section -CreateShortcuts
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\HomePage.url"     "InternetShortcut" "URL" "${KICAD_MAIN_SITE}"
  WriteIniStr "$INSTDIR\UserGroup.url"    "InternetShortcut" "URL" "${HELP_WEB_SITE}"
  WriteIniStr "$INSTDIR\DevelGroup.url"   "InternetShortcut" "URL" "${DEVEL_WEB_SITE}"
  WriteIniStr "$INSTDIR\LibrariesGroup.url" "InternetShortcut" "URL" "${LIBRARIES_WEB_SITE}"
  WriteIniStr "$INSTDIR\Wings3D.url"      "InternetShortcut" "URL" "${WINGS3D_WEB_SITE}"
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\KiCad"
  CreateShortCut "$SMPROGRAMS\KiCad\Home Page.lnk" "$INSTDIR\HomePage.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad Libraries.lnk" "$INSTDIR\LibrariesGroup.url"
  CreateShortCut "$SMPROGRAMS\KiCad\Wings3D.lnk" "$INSTDIR\Wings3D.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad User Group.lnk" "$INSTDIR\UserGroup.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad Devel Group.lnk" "$INSTDIR\DevelGroup.url"
  CreateShortCut "$SMPROGRAMS\KiCad\Uninstall.lnk" "$INSTDIR\uninstaller.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad.lnk" "$INSTDIR\bin\kicad.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Eeschema.lnk" "$INSTDIR\bin\eeschema.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Pcbnew.lnk" "$INSTDIR\bin\pcbnew.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Gerbview.lnk" "$INSTDIR\bin\gerbview.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Bitmap2component.lnk" "$INSTDIR\bin\bitmap2component.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\PCB calculator.lnk" "$INSTDIR\bin\pcb_calculator.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Pagelayout editor.lnk" "$INSTDIR\bin\pl_editor.exe"
  CreateShortCut "$DESKTOP\KiCad.lnk" "$INSTDIR\bin\kicad.exe"
SectionEnd

Section -CreateAddRemoveEntry
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "Publisher" "${COMPANY_NAME}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstaller.exe"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${KICAD_MAIN_SITE}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\bin\kicad.exe"
  WriteRegDWORD ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "NoModify" "1"
  WriteRegDWORD ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "NoRepair" "1"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "Comments" "${COMMENTS}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "HelpLink" "${HELP_WEB_SITE}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "URLUpdateInfo" "${KICAD_MAIN_SITE}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"

  WriteUninstaller "$INSTDIR\uninstaller.exe"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} $(DESC_SEC_MAIN)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} $(DESC_SEC_SCHLIB)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} $(DESC_SEC_FPLIB)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} $(DESC_SEC_FPWIZ)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} $(DESC_SEC_DEMOS)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06} $(DESC_SEC_DOCS)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_EN} $(DESC_SEC_DOCS_EN)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_DE} $(DESC_SEC_DOCS_DE)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_ES} $(DESC_SEC_DOCS_ES)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_FR} $(DESC_SEC_DOCS_FR)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_IT} $(DESC_SEC_DOCS_IT)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_JA} $(DESC_SEC_DOCS_JA)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_NL} $(DESC_SEC_DOCS_NL)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06_PL} $(DESC_SEC_DOCS_PL)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

Function un.myGuiInit
  Call un.PreventMultiInstances
  MessageBox MB_ICONEXCLAMATION|MB_YESNO|MB_DEFBUTTON2 $(UNINST_PROMPT) /SD IDYES IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK $(UNINST_SUCCESS) /SD IDOK
FunctionEnd

Section Uninstall
  ;delete uninstaller first
  Delete "$INSTDIR\uninstaller.exe"

  ;remove start menu shortcuts and web page links
  SetShellVarContext all
  Delete "$SMPROGRAMS\KiCad\Home Page.lnk"
  Delete "$SMPROGRAMS\KiCad\KiCad Libraries.lnk"
  Delete "$SMPROGRAMS\KiCad\KiCad Alternate Download.lnk"
  Delete "$SMPROGRAMS\KiCad\KiCad Devel Group.lnk"
  Delete "$SMPROGRAMS\KiCad\KiCad User Group.lnk"
  Delete "$SMPROGRAMS\KiCad\Uninstall.lnk"
  Delete "$SMPROGRAMS\KiCad\Wings3D.lnk"
  Delete "$SMPROGRAMS\KiCad\KiCad.lnk"
  Delete "$SMPROGRAMS\KiCad\Eeschema.lnk"
  Delete "$SMPROGRAMS\KiCad\Pcbnew.lnk"
  Delete "$SMPROGRAMS\KiCad\Gerbview.lnk"
  Delete "$SMPROGRAMS\KiCad\Bitmap2component.lnk"
  Delete "$SMPROGRAMS\KiCad\PCB calculator.lnk"
  Delete "$SMPROGRAMS\KiCad\Pagelayout editor.lnk"
  Delete "$DESKTOP\KiCad.lnk"
  Delete "$INSTDIR\Wings3D.url"
  Delete "$INSTDIR\HomePage.url"
  Delete "$INSTDIR\UserGroup.url"
  Delete "$INSTDIR\AltDownloadSite.url"
  Delete "$INSTDIR\DevelGroup.url"
  Delete "$INSTDIR\LibrariesGroup.url"
  RMDir "$SMPROGRAMS\KiCad"

  ;remove all program files now
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\library"
  RMDir /r "$INSTDIR\modules"
  RMDir /r "$INSTDIR\template"
  RMDir /r "$INSTDIR\internat"
  RMDir /r "$INSTDIR\demos"
  RMDir /r "$INSTDIR\tutorials"
  RMDir /r "$INSTDIR\help"
  RMDir /r "$INSTDIR\share\library"
  RMDir /r "$INSTDIR\share\modules"
  RMDir /r "$INSTDIR\share\kicad\template"
  RMDir /r "$INSTDIR\share\kicad\internat"
  RMDir /r "$INSTDIR\share\kicad\demos"
  RMDir /r "$INSTDIR\share\doc\kicad\tutorials"
  RMDir /r "$INSTDIR\share\doc\kicad\help"
  RMDir /r "$INSTDIR\share\doc\kicad"
  RMDir /r "$INSTDIR\share\doc"
  RMDir /r "$INSTDIR\share"
  RMDir /r "$INSTDIR\wings3d"
  RMDir /r "$INSTDIR\ssl\certs"
  RMDir /r "$INSTDIR\ssl"
  ;don't remove $INSTDIR recursively just in case the user has installed it in c:\ or
  ;c:\program files as this would attempt to delete a lot more than just this package
  Delete "$INSTDIR\*.txt"
  RMDir "$INSTDIR"

  ;remove environment only if it was "installed" last
  ClearErrors
  ReadRegDWORD $0 ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "EnvInstalled"
  IfErrors FinishUninstall 0
  
  IntCmp $0 1 0 FinishUninstall FinishUninstall
  
  DeleteRegValue ${ENV_HKLM} KICAD_PTEMPLATES
  DeleteRegValue ${ENV_HKLM} KISYS3DMOD
  DeleteRegValue ${ENV_HKLM} KISYSMOD
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  
  FinishUninstall:
  ;Note - application registry keys are stored in the users individual registry hive (HKCU\Software\kicad".
  ;It might be possible to remove these keys as well but it would require a lot of testing of permissions
  ;and access to other people's registry entries. So for now we will leave the application registry keys.

  ;remove installation registary keys
  DeleteRegKey ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd

Function PreventMultiInstances
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION $(INSTALLER_RUNNING) /SD IDOK
  Abort
FunctionEnd

Function un.PreventMultiInstances
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION $(UNINSTALLER_RUNNING) /SD IDOK
  Abort
FunctionEnd

Function CheckAlreadyInstalled
  ReadRegStr $R0 ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayName"
  StrCmp $R0 "" +3
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $(ALREADY_INSTALLED) /SD IDOK IDOK +2
  Abort
FunctionEnd
