VERSION 5.00
Begin VB.Form editTileBitmap 
   Caption         =   "Untitled tile bitmap"
   ClientHeight    =   4515
   ClientLeft      =   60
   ClientTop       =   630
   ClientWidth     =   6585
   Icon            =   "editTileBitmap.frx":0000
   LinkTopic       =   "Form2"
   MDIChild        =   -1  'True
   MinButton       =   0   'False
   ScaleHeight     =   4515
   ScaleWidth      =   6585
   Tag             =   "10"
   Begin VB.PictureBox arena 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   3495
      Left            =   120
      MousePointer    =   2  'Cross
      ScaleHeight     =   233
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   385
      TabIndex        =   0
      Top             =   120
      Width           =   5775
   End
   Begin VB.Menu mnuFile 
      Caption         =   "File"
      Begin VB.Menu mnuNewProject 
         Caption         =   "New Project"
         Shortcut        =   ^N
      End
      Begin VB.Menu mnuNew 
         Caption         =   "New..."
         Begin VB.Menu mnuNewTile 
            Caption         =   "Tile"
         End
         Begin VB.Menu mnuNewAnimatedTile 
            Caption         =   "Animated Tile"
         End
         Begin VB.Menu mnuNewBoard 
            Caption         =   "Board"
         End
         Begin VB.Menu mnuNewPlayer 
            Caption         =   "Player"
         End
         Begin VB.Menu mnuNewItem 
            Caption         =   "Item"
         End
         Begin VB.Menu mnuNewEnemy 
            Caption         =   "Enemy"
         End
         Begin VB.Menu mnuNewRPGCodeProgram 
            Caption         =   "RPGCode Program"
         End
         Begin VB.Menu mnuNewFightBackground 
            Caption         =   "Fight Background"
         End
         Begin VB.Menu mnuNewSpecialMove 
            Caption         =   "Special Move"
         End
         Begin VB.Menu mnuNewStatusEffect 
            Caption         =   "Status Effect"
         End
         Begin VB.Menu mnuNewAnimation 
            Caption         =   "Animation"
         End
         Begin VB.Menu mnuNewTileBitmap 
            Caption         =   "Tile Bitmap"
         End
      End
      Begin VB.Menu sub1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuOpenProject 
         Caption         =   "Open Project"
      End
      Begin VB.Menu mnuOpen 
         Caption         =   "Open"
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuSave 
         Caption         =   "Save Tile Bitmap"
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuSaveAs 
         Caption         =   "Save Tile Bitmap As..."
         Shortcut        =   ^A
      End
      Begin VB.Menu mnuSaveAll 
         Caption         =   "Save All"
      End
      Begin VB.Menu sub2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuCLose 
         Caption         =   "Close"
      End
      Begin VB.Menu mnuExit 
         Caption         =   "Exit"
      End
   End
   Begin VB.Menu mnuToolkit 
      Caption         =   "Toolkit"
      Begin VB.Menu mnuTestGame 
         Caption         =   "Test Game"
         Shortcut        =   {F5}
      End
      Begin VB.Menu mnuSelectLanguage 
         Caption         =   "Select Language"
         Shortcut        =   ^L
      End
      Begin VB.Menu sub3 
         Caption         =   "-"
         Visible         =   0   'False
      End
      Begin VB.Menu mnuInstallUpgrade 
         Caption         =   "Install Upgrade"
         Visible         =   0   'False
      End
   End
   Begin VB.Menu mnuBuild 
      Caption         =   "Build"
      Begin VB.Menu mnuCreatePakFile 
         Caption         =   "Create PakFile"
      End
      Begin VB.Menu mnuMakeEXE 
         Caption         =   "Make EXE"
         Shortcut        =   {F7}
      End
      Begin VB.Menu sub4 
         Caption         =   "-"
      End
      Begin VB.Menu mnuCreateSetup 
         Caption         =   "Create Setup"
      End
   End
   Begin VB.Menu mnuWindow 
      Caption         =   "Window"
      WindowList      =   -1  'True
      Begin VB.Menu mnuShowTools 
         Caption         =   "Show/Hide Tools"
      End
      Begin VB.Menu mnuShowProjectList 
         Caption         =   "Show/Hide Project List"
      End
   End
   Begin VB.Menu h 
      Caption         =   "Help"
      Tag             =   "1206"
      Begin VB.Menu mnuusersguide 
         Caption         =   "User's Guide"
         Shortcut        =   {F1}
         Tag             =   "1207"
      End
      Begin VB.Menu sub6 
         Caption         =   "-"
      End
      Begin VB.Menu mnuTutorial 
         Caption         =   "Tutorial"
         Visible         =   0   'False
      End
      Begin VB.Menu mnuhistorytxt 
         Caption         =   "History.txt"
      End
      Begin VB.Menu sub7 
         Caption         =   "-"
      End
      Begin VB.Menu mnuregistrationinfo 
         Caption         =   "Registration Info"
         Visible         =   0   'False
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "About"
      End
   End
End
Attribute VB_Name = "editTileBitmap"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'========================================================================
' The RPG Toolkit, Version 3
' This file copyright (C) 2007 Christopher Matthews & contributors
'
' Contributors:
'    - Colin James Fitzpatrick
'    - Jonathan D. Hughes
'========================================================================
'
' This program is free software; you can redistribute it and/or
' modify it under the terms of the GNU General Public License
' as published by the Free Software Foundation; either version 2
' of the License, or (at your option) any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.
'
'========================================================================

Option Explicit
Public dataIndex As Long    'index into the vector of tbms

Private m_bIgnore As Boolean

Public Sub changeSelectedTile(ByVal file As String): On Error Resume Next
    
    If LenB(file) = 0 Then Exit Sub
    tileBmpList(activeTileBmpIndex).selectedTile = file
    
    Call openWinTile(projectPath & tilePath & file)
    If detail = 2 Or detail = 4 Or detail = 6 Then Call increaseDetail
    
    Dim dx As Long, dy As Long, colorDraw As Long
    
    detail = openTileEditorDocs(activeTile.indice).oldDetail
    For dx = 1 To 32
        For dy = 1 To 32
            colorDraw = tileMem(dx, dy)
            If colorDraw = -1 Then colorDraw = vbQBColor(15)
            Call vbPicPSet(tkMainForm.tileBmpSelectedTile, dx - 1, dy - 1, colorDraw)
        Next dy
    Next dx
    tkMainForm.tilebmpCurrentTile.Caption = tileBmpList(activeTileBmpIndex).selectedTile$

End Sub

Public Function formType() As Long: On Error Resume Next
    formType = FT_TILEBITMAP
End Function

Public Sub changeColor(): On Error Resume Next
    Dim c As Long
    c = ColorDialog()
    If (c <> -1) Then
        tileBmpList(activeTileBmpIndex).ambientR = red(c)
        tileBmpList(activeTileBmpIndex).ambientG = green(c)
        tileBmpList(activeTileBmpIndex).ambientB = blue(c)
        Call vbPicFillRect(tkMainForm.tilebmpColor, 0, 0, 1000, 1000, c)
    End If
End Sub

Public Sub saveFile(): On Error Resume Next
    'If tileBmpList(activeTileBmpIndex).needUpdate = True Then
        
        tileBmpList(activeTileBmpIndex).needUpdate = False
        If LenB(tileBmpList(activeTileBmpIndex).filename) = 0 Then
            Me.Show
            mnusaveas_Click
            Exit Sub
        End If
        
        Dim strFile As String
        strFile = projectPath & bmpPath & tileBmpList(activeTileBmpIndex).filename
        
        If (fileExists(strFile)) Then
            If (GetAttr(strFile) And vbReadOnly) Then
                Call MsgBox("This file is read-only; please choose a different file.")
                Call saveAsFile
                Exit Sub
            End If
        End If
        
        Call SaveTileBitmap(strFile, tileBmpList(activeTileBmpIndex).theData)
        Me.Caption = tileBmpList(activeTileBmpIndex).filename
        
    'End If
End Sub

Public Sub saveAsFile(): On Error Resume Next
    If tileBmpList(activeTileBmpIndex).needUpdate = True Then
        Me.Show
        mnusaveas_Click
    End If
End Sub

Public Sub checkSave(): On Error Resume Next
    If tileBmpList(activeTileBmpIndex).needUpdate = True Then
        If MsgBox("Save changes to " & tileBmpList(activeTileBmpIndex).filename & "?", vbYesNo) = vbYes Then
            Call saveFile
        End If
    End If
End Sub

Private Sub infofill(): On Error Resume Next
    
    Dim xx As Long, yy As Long, x As Long, y As Long
    
    xx = tileBmpList(activeTileBmpIndex).theData.sizex
    yy = tileBmpList(activeTileBmpIndex).theData.sizey
    
    arena.width = xx * 32 * Screen.TwipsPerPixelX
    arena.Height = yy * 32 * Screen.TwipsPerPixelY
      
    Me.width = arena.width + 1200
    Me.Height = arena.Height + 1200
    arena.Left = 500
    arena.Top = 400
   
    Call vbPicCls(arena)
    
    Call GFXClearTileCache
    Call DrawTileBitmap(vbPicHDC(arena), -1, 0, 0, tileBmpList(activeTileBmpIndex).theData)
    Call vbPicRefresh(arena)
    
    If tileBmpList(activeTileBmpIndex).grid = 1 Then
        For x = 0 To xx * 32 Step 32
            Call vbPicLine(arena, x, 0, x, yy * 32, vbQBColor(1))
        Next x
        For y = 0 To yy * 32 Step 32
            Call vbPicLine(arena, 0, y, xx * 32, y, vbQBColor(1))
        Next y
    End If
    
    'fill in other info
    tkMainForm.tilebmpSizeX.Text = CStr(xx)
    tkMainForm.tileBmpSizeY.Text = CStr(yy)
    
    Call vbPicFillRect(tkMainForm.tilebmpColor, 0, 0, 1000, 1000, RGB(tileBmpList(activeTileBmpIndex).ambientR, tileBmpList(activeTileBmpIndex).ambientG, tileBmpList(activeTileBmpIndex).ambientB))
    
    If tileBmpList(activeTileBmpIndex).selectedTile <> "" Then
        Call drawTile(vbPicHDC(tkMainForm.tileBmpSelectedTile), tilePath$ + tileBmpList(activeTileBmpIndex).selectedTile, 1, 1, 0, 0, 0, False)
        Call vbPicRefresh(tkMainForm.tileBmpSelectedTile)
        tkMainForm.tilebmpCurrentTile.Caption = tileBmpList(activeTileBmpIndex).selectedTile$
    Else
        Call vbPicFillRect(tkMainForm.tileBmpSelectedTile, 0, 0, 1000, 1000, RGB(255, 255, 255))
        tkMainForm.tilebmpCurrentTile.Caption = tileBmpList(activeTileBmpIndex).selectedTile$
    End If
    
    If tileBmpList(activeTileBmpIndex).drawState = 0 Then
        ignore = 1
        tkMainForm.tilebmpDrawLock.value = 1
        tkMainForm.tilebmpEraser.value = 0
        ignore = 0
    Else
        ignore = 1
        tkMainForm.tilebmpDrawLock.value = 0
        tkMainForm.tilebmpEraser.value = 1
        ignore = 0
    End If
End Sub

Public Sub openFile(ByVal filename As String): On Error Resume Next
    activeTileBmp.Show
    Call checkSave
    
    Call OpenTileBitmap(filename, tileBmpList(activeTileBmpIndex).theData)
    
    'Preserve the path if file is in a sub-folder.
    Call getValidPath(filename, projectPath & bmpPath, tileBmpList(activeTileBmpIndex).filename, False)
    Me.Caption = tileBmpList(activeTileBmpIndex).filename
    
    Call infofill
    tileBmpList(activeTileBmpIndex).needUpdate = False
End Sub

Public Sub tileBmpAmbientSlider(): On Error Resume Next
    tileBmpList(activeTileBmpIndex).ambientR = tkMainForm.tileBmpAmbientSlider.value
    tileBmpList(activeTileBmpIndex).ambientG = tkMainForm.tileBmpAmbientSlider.value
    tileBmpList(activeTileBmpIndex).ambientB = tkMainForm.tileBmpAmbientSlider.value
    tkMainForm.tileBmpAmbient.Text = CStr(tkMainForm.tileBmpAmbientSlider.value)
    Call vbPicFillRect(tkMainForm.tilebmpColor, 0, 0, 1000, 1000, RGB(tileBmpList(activeTileBmpIndex).ambientR, tileBmpList(activeTileBmpIndex).ambientG, tileBmpList(activeTileBmpIndex).ambientB))
End Sub

Private Sub changeDrawState(ByVal lngNewState As Long): On Error Resume Next
    tileBmpList(activeTileBmpIndex).drawState = lngNewState
    m_bIgnore = True
    tkMainForm.tilebmpEraser.value = lngNewState
    tkMainForm.tilebmpDrawLock.value = IIf(lngNewState, 0, 1)
    m_bIgnore = False
End Sub

Public Sub tilebmpDrawLock(): On Error Resume Next
    If (m_bIgnore) Then Exit Sub
    Call changeDrawState(0)
End Sub

Public Sub tilebmpEraser(): On Error Resume Next
    If (m_bIgnore) Then Exit Sub
    Call changeDrawState(1)
End Sub

Public Sub tilebmpGrid(ByVal val As Long): On Error Resume Next
    tileBmpList(activeTileBmpIndex).grid = val
    Call infofill
End Sub

Public Sub tilebmpRedraw(): On Error Resume Next
    Call infofill
End Sub

Public Sub tilebmpSelectTile(): On Error Resume Next
    ignore = 1
    openTileEditorDocs(activeTile.indice).oldDetail = detail
    
    Dim x As Long, y As Long
    Dim antiPath As String
    Dim tstnum As Long
    Dim whichType As String
    Dim dx As Long, dy As Long, colorDraw As Long
    
    For x = 1 To 32
        For y = 1 To 32
            bufTile(x, y) = tileMem(x, y)
        Next y
    Next x
    
    Dim file As String, fileTypes As String, ext As String
    fileTypes = "Supported Types|*.gph;*.tst|RPG Toolkit Tile (*.gph)|*.gph|RPG Toolkit TileSet (*.tst)|*.tst|All files(*.*)|*.*"
    
    If Not browseFileDialog(Me.hwnd, projectPath & tilePath, "Select tile", "tst", fileTypes, file) Then
        Exit Sub
    End If
    
    ext = UCase$(extention(file))
    If ext = "TST" Then
        tstnum = 0
        
        tstFile = file
        configfile.lastTileset = file
        tilesetForm.Show vbModal
        
        Call changeSelectedTile(setFilename)
    Else
        tileBmpList(activeTileBmpIndex).selectedTile = file
        Call openWinTile(file)
        If detail = 2 Or detail = 4 Or detail = 6 Then Call increaseDetail
        
        detail = openTileEditorDocs(activeTile.indice).oldDetail
        For dx = 1 To 32
            For dy = 1 To 32
                colorDraw = tileMem(dx, dy)
                If colorDraw = -1 Then colorDraw = vbQBColor(15)
                Call vbPicPSet(tkMainForm.tileBmpSelectedTile, dx - 1, dy - 1, colorDraw)
            Next dy
        Next dx
        Call vbPicRefresh(tkMainForm.tileBmpSelectedTile)
        tkMainForm.tilebmpCurrentTile.Caption = tileBmpList(activeTileBmpIndex).selectedTile$
    End If
    
    For x = 1 To 32
        For y = 1 To 32
            tileMem(x, y) = bufTile(x, y)
        Next y
    Next x
End Sub

Public Sub tilebmpSizeX(): On Error Resume Next
    If val(tkMainForm.tilebmpSizeX) > 40 Then
        tkMainForm.tilebmpSizeX.Text = "40"
    End If
End Sub

Public Sub tileBmpSizeY(): On Error Resume Next
    If val(tkMainForm.tileBmpSizeY) > 40 Then
        tkMainForm.tileBmpSizeY.Text = "40"
    End If
End Sub

Public Sub tileBmpSizeOK(): On Error Resume Next
    Dim sx As Long, sy As Long
    sx = val(tkMainForm.tilebmpSizeX)
    sy = val(tkMainForm.tileBmpSizeY)
    
    Call TileBitmapResize(tileBmpList(activeTileBmpIndex).theData, sx, sy)
    Call infofill
End Sub

Private Sub arena_KeyPress(ByRef ascii As Integer): On Error Resume Next
    If (UCase$(chr$(ascii)) = "L") Then
        If (LenB(configfile.lastTileset)) Then
            tstFile = configfile.lastTileset

            Dim strExt As String
            strExt = UCase$(commonRoutines.extention(tstFile))
            
            If (strExt = "TST") Then
                Call tilesetForm.Show(vbModal)
                Call changeSelectedTile(setFilename)
            End If
        Else
            Call tilebmpSelectTile
        End If
    End If
End Sub

Private Sub arena_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single): On Error Resume Next
    
    Dim xx As Long, yy As Long, x2 As Long, y2 As Long
    
    xx = Int(x / 32) + tileBmpList(activeTileBmpIndex).topX
    yy = Int(y / 32) + tileBmpList(activeTileBmpIndex).topY
    
    x2 = Int(x / 32)
    y2 = Int(y / 32)
    
    tileBmpList(activeTileBmpIndex).needUpdate = True
    Select Case tileBmpList(activeTileBmpIndex).drawState
        Case 0:
            'draw lock
            If tileBmpList(activeTileBmpIndex).selectedTile <> "" Then
                Call drawTile(vbPicHDC(arena), _
                                tilePath$ + tileBmpList(activeTileBmpIndex).selectedTile, _
                                x2 + 1, _
                                y2 + 1, _
                                tileBmpList(activeTileBmpIndex).ambientR, _
                                tileBmpList(activeTileBmpIndex).ambientG, _
                                tileBmpList(activeTileBmpIndex).ambientB, _
                                False)
                Call vbPicRefresh(arena)
                
                tileBmpList(activeTileBmpIndex).theData.tiles(xx, yy) = tileBmpList(activeTileBmpIndex).selectedTile
                tileBmpList(activeTileBmpIndex).theData.redS(xx, yy) = tileBmpList(activeTileBmpIndex).ambientR
                tileBmpList(activeTileBmpIndex).theData.greenS(xx, yy) = tileBmpList(activeTileBmpIndex).ambientG
                tileBmpList(activeTileBmpIndex).theData.blueS(xx, yy) = tileBmpList(activeTileBmpIndex).ambientB
            End If
        Case 1:
            'eraser
            Call vbPicFillRect(arena, x2 * 32, y2 * 32, x2 * 32 + 32, y2 * 32 + 32, RGB(255, 255, 255))
            Call vbPicRefresh(arena)
            
            tileBmpList(activeTileBmpIndex).theData.tiles(xx, yy) = ""
            tileBmpList(activeTileBmpIndex).theData.redS(xx, yy) = 0
            tileBmpList(activeTileBmpIndex).theData.greenS(xx, yy) = 0
            tileBmpList(activeTileBmpIndex).theData.blueS(xx, yy) = 0
    End Select
End Sub

Private Sub arena_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single): On Error Resume Next
    Dim xx As Long, yy As Long
    
    xx = Int(x / 32) + tileBmpList(activeTileBmpIndex).topX
    yy = Int(y / 32) + tileBmpList(activeTileBmpIndex).topY
    tkMainForm.tileBmpCoords.Caption = str$(xx + 1) + "," + str$(yy + 1)
    If Button <> 0 Then
        Call arena_MouseDown(Button, Shift, x, y)
    End If
End Sub


Private Sub Form_Activate(): On Error Resume Next
    Set activeTileBmp = Me
    Set activeForm = Me
    activeTileBmpIndex = dataIndex
    Call hideAllTools
    tkMainForm.bBar.visible = True
    tkMainForm.tileBmpExtras.visible = True
    tkMainForm.tilebmpTools.visible = True
    tkMainForm.tilebmpTools.Top = tkMainForm.toolTop
End Sub

Private Sub Form_Load(): On Error Resume Next
    
    Set activeTileBmp = Me
    dataIndex = VectTileBmpNewSlot()
    activeTileBmpIndex = dataIndex
    Call TileBitmapClear(tileBmpList(dataIndex).theData)
    
    Call infofill
End Sub

Private Sub Form_Resize(): On Error Resume Next
    'arena.Left = (Me.width - arena.width) / 2
    'arena.Top = (Me.Height - arena.Height) / 2
End Sub

Private Sub Form_Unload(Cancel As Integer): On Error Resume Next
    Call hideAllTools
    Call tkMainForm.refreshTabs
End Sub

Private Sub mnuCLose_Click(): On Error Resume Next
    Unload Me
End Sub

Private Sub mnusaveas_Click(): On Error Resume Next
    
    Dim dlg As FileDialogInfo
    
    dlg.strDefaultFolder = projectPath & bmpPath
    dlg.strTitle = "Save Tile Bitmap As"
    dlg.strDefaultExt = "tbm"
    dlg.strFileTypes = "RPG Toolkit Tile Bitmap (*.tbm)|*.tbm|All files(*.*)|*.*"
    
    If Not SaveFileDialog(dlg, Me.hwnd) Then Exit Sub
    If LenB(dlg.strSelectedFileNoPath) = 0 Then Exit Sub
    
    'Preserve the path if a sub-folder is chosen.
    If Not getValidPath(dlg.strSelectedFile, dlg.strDefaultFolder, tileBmpList(activeTileBmpIndex).filename, True) Then Exit Sub
   
    Call SaveTileBitmap(dlg.strDefaultFolder & tileBmpList(activeTileBmpIndex).filename, tileBmpList(activeTileBmpIndex).theData)
    Me.Caption = tileBmpList(activeTileBmpIndex).filename

    tileBmpList(activeTileBmpIndex).needUpdate = False
    Call tkMainForm.tvAddFile(dlg.strDefaultFolder & tileBmpList(activeTileBmpIndex).filename)
End Sub


Private Sub toc_Click()
    On Error Resume Next
    Call BrowseFile(helpPath$ + ObtainCaptionFromTag(DB_Help1, resourcePath$ + m_LangFile))
End Sub

Private Sub mnutilehorizontally_Click()
    On Error Resume Next
    Call tkMainForm.tilehorizonatllymnu_Click
End Sub

Private Sub mnutilevertically_Click()
    On Error Resume Next
    Call tkMainForm.tileverticallymnu_Click
End Sub

Private Sub mnuTutorial_Click()
    On Error Resume Next
    Call tkMainForm.tutorialmnu_Click
End Sub

Private Sub mnuusersguide_Click()
    On Error Resume Next
    Call tkMainForm.usersguidemnu_Click
End Sub

Private Sub mnuAbout_Click()
    On Error Resume Next
    Call tkMainForm.aboutmnu_Click
End Sub

Private Sub mnuArrangeIcons_Click()
    On Error Resume Next
    Call tkMainForm.arrangeiconsmnu_Click
End Sub

Private Sub mnuCascade_Click()
    On Error Resume Next
    Call tkMainForm.cascademnu_Click
End Sub

Private Sub mnucreatepakfile_Click()
    On Error Resume Next
    Call tkMainForm.createpakfilemnu_Click
End Sub

Private Sub mnucreatesetup_Click()
    On Error Resume Next
    Call tkMainForm.createsetupmnu_Click
End Sub

Private Sub mnuexit_Click()
    On Error Resume Next
    Call tkMainForm.exitmnu_Click
End Sub

Private Sub mnuHistorytxt_Click()
    On Error Resume Next
    Call tkMainForm.historytxtmnu_Click
End Sub

Private Sub mnuinstallupgrade_Click()
    On Error Resume Next
    Call tkMainForm.installupgrademnu_Click
End Sub

Private Sub mnumakeexe_Click()
    On Error Resume Next
    Call tkMainForm.makeexemnu_Click
End Sub

Private Sub mnunewanimatedtile_Click()
    On Error Resume Next
    Call tkMainForm.newanimtilemnu_Click
End Sub

Private Sub mnunewanimation_Click()
    On Error Resume Next
    Call tkMainForm.newanimationmnu_Click
End Sub

Private Sub mnunewboard_Click()
    On Error Resume Next
    Call tkMainForm.newboardmnu_Click
End Sub

Private Sub mnunewenemy_Click()
    On Error Resume Next
    Call tkMainForm.newenemymnu_Click
End Sub

Private Sub mnunewitem_Click()
    On Error Resume Next
    Call tkMainForm.newitemmnu_Click
End Sub

Private Sub mnunewplayer_Click()
    On Error Resume Next
    Call tkMainForm.newplayermnu_Click
End Sub

Private Sub mnunewproject_Click()
    On Error Resume Next
    Call tkMainForm.newprojectmnu_Click
End Sub

Private Sub mnunewrpgcodeprogram_Click()
    On Error Resume Next
    Call tkMainForm.newrpgcodemnu_Click
End Sub

Private Sub mnunewspecialmove_Click()
    On Error Resume Next
    Call tkMainForm.newspecialmovemnu_Click
End Sub

Private Sub mnunewstatuseffect_Click()
    On Error Resume Next
    Call tkMainForm.newstatuseffectmnu_Click
End Sub

Private Sub mnunewtile_Click()
    On Error Resume Next
    Call tkMainForm.newtilemnu_Click
End Sub

Private Sub mnunewtilebitmap_Click()
    On Error Resume Next
    Call tkMainForm.newtilebitmapmnu_Click
End Sub

Private Sub mnuopen_Click()
    On Error Resume Next
    Call tkMainForm.openmnu_Click
End Sub

Private Sub mnuRegistrationInfo_Click()
    On Error Resume Next
    Call tkMainForm.registrationinfomnu_Click
End Sub

Private Sub mnuRPGCodePrimer_Click()
    On Error Resume Next
    Call tkMainForm.rpgcodeprimermnu_Click
End Sub

Private Sub mnurpgcodereference_Click()
    On Error Resume Next
    Call tkMainForm.rpgcodereferencemnu_Click
End Sub

Private Sub mnusave_Click()
    On Error Resume Next
    Call tkMainForm.savemnu_Click
End Sub

Private Sub mnusaveall_Click()
    On Error Resume Next
    Call tkMainForm.saveallmnu_Click
End Sub

Private Sub mnuselectlanguage_Click()
    On Error Resume Next
    Call tkMainForm.selectlanguagemnu_Click
End Sub

Private Sub mnushowprojectlist_Click()
    On Error Resume Next
    Call tkMainForm.showprojectlistmnu_Click
End Sub

Private Sub mnushowtools_Click()
    On Error Resume Next
    Call tkMainForm.showtoolsmnu_Click
End Sub

Private Sub mnutestgame_Click()
    On Error Resume Next
    tkMainForm.testgamemnu_Click
End Sub

Private Sub mnuOpenProject_Click()
    On Error Resume Next
    Call tkMainForm.mnuOpenProject_Click
End Sub

Private Sub mnuNewFightBackground_Click()
    On Error Resume Next
    Call tkMainForm.mnuNewFightBackground_Click
End Sub

