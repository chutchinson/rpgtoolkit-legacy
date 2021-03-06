Attribute VB_Name = "CommonTileDoc"
'========================================================================
' The RPG Toolkit, Version 3
' This file copyright (C) 2007 Christopher Matthews & contributors
'
' Contributors:
'    - Colin James Fitzpatrick
'    - Jonathan D. Hughes
'    - Sander Knape
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

#If isToolkit = 0 Then
    Public publicTile As Object
    Public detail As Byte
    Public tileMem(64, 32) As Long
#End If

'========================================================================
' Other variables
'========================================================================
Public tilePreview(64, 32) As Long      'Used for some effects
Public saveChanges As Boolean           'Used for the effects
Public isoMaskBmp(64, 32) As Long       'Isomask loaded from frmMain
Public xRange As Integer                '= 32 OR 64 depending on tiletype. This way we don't
                                        'need to make new tileMem.

#If isToolkit = 1 Then

Public Sub tileDrawIso(ByRef pic As PictureBox, ByVal xLoc As Long, ByVal yLoc As Long, Optional ByVal quality As Integer = 0)
'=====================================================================
'draw a tile isometrically
'quality 0 = low (no blending)
' 1= medium (blending on the size-up)
' 2= high (blending on the size-up and size down)
' 3= very high (blending on size up and extreme blending on size-down)
' ISODETAIL = draw new .iso tiletype. Added for 3.0.4!
'=====================================================================
'Edited Delano for 3.0.4
'Additions for the new isometric tile system.
'Placed rotation code in it's own sub.
    
'Called by: tileedit    tileredraw [isomirror]
'           boardedit   changeselectedtile [currentisotile]
'                       boardselecttile [currentisotile]
'           tilesetadd
    
    On Error Resume Next
    
    Dim xCount As Integer, yCount As Integer
    Dim x As Long, y As Long
    
    If quality = ISODETAIL Then
        'Tile doesn't need rotating or deforming. Can draw it straight off.

        'Set up the count for tilemem.
        xCount = 1: yCount = 1

        'We loop over isoMaskBmp on each pixel - if the pixel is
        'unmasked we draw the *next* entry in tilemem (NOT the corresponding
        'x, y entry!!). If the pixel is masked, we don't draw it.
        
        'The isoMaskBmp is created by the function below and loaded in tkMain Form_load so as
        'to be available to all editors.

        For x = 1 To 64
            For y = 1 To 32
                If isoMaskBmp(x, y) = RGB(0, 0, 0) Then
                    'Unmasked pixel - use the next pixel in tilemem.
                    'Set it to the (x - 1)'th and (y -1)'th pixels!!
                    Call vbPicPSet(pic, x - 1 + xLoc, y - 1 + yLoc, tileMem(xCount, yCount))

                    'Increment the tilemem entry.
                    yCount = yCount + 1
                    If yCount > 32 Then
                        xCount = xCount + 1
                        yCount = 1
                    End If

                End If
            Next y
        Next x

        Exit Sub

    End If 'quality = ISODETAIL
    
    'Else, we call tst -> iso and draw
    
    Call tstToIsometric(quality)
    
    For x = 0 To 64
        For y = 0 To 32
            If bufTile(x, y) <> -1 Then
                Call vbPicPSet(pic, x + xLoc, y + yLoc, bufTile(x, y))
            Else
                If isoMaskBmp(x, y) = RGB(0, 0, 0) Then
                    Call vbPicPSet(pic, x + xLoc, y + yLoc, RGB(255, 255, 255))
                End If
            End If
        Next y
    Next x
    
End Sub

Public Sub createIsoMask(): On Error Resume Next
'================================================
'New function: Added for 3.0.4 by Delano
'Creates the isoMaskBmp mask from the rotation code.
'Called in tkMainForm Form_Load only!
'Only needs to be called once!
'================================================
    
    'First, we make tilemem a black tile:
    Dim x As Long, y As Long
    
    For x = 0 To 64
        For y = 0 To 32
            tileMem(x, y) = RGB(0, 0, 0)
            isoMaskBmp(x, y) = RGB(255, 255, 255)   'Initialize the mask.
        Next y
    Next x
    
    'Now, pass it through the tst to iso conversion - this operates on tilemem and
    'creates an isometric tile in the buffer tile.
    
    Call tstToIsometric
    
    'Now we create the mask from the tile. The tile is offset and is slightly too wide
    'so we copy in halves. And erase tilemem while we're at it.
    
    For x = 0 To 32
        For y = 0 To 32
            isoMaskBmp(x + 1, y + 1) = bufTile(x, y)
            tileMem(x, y) = -1
        Next y
    Next x
    
    '2nd half. Note x-index!
    
    For x = 33 To 64
        For y = 0 To 32
            'Insert into x, not x + 1!
            isoMaskBmp(x, y + 1) = bufTile(x, y)
            tileMem(x, y) = -1
        Next y
    Next x
    
End Sub

Function getIsoX(ByVal x As Long, ByVal y As Long) As Long
    'convert a 2d x coord to the corresponding isometric coord in a tile
    'starts from 0
    
    On Error Resume Next
    
    Dim tX As Long, tY As Long, xx As Long, yy As Long
    tX = x
    tY = y
    
    xx = 62 + (tX) * 2 - (tY) * 2
    yy = (tX) + (tY)
                        
    getIsoX = (xx) \ 2

End Function

Function getIsoY(ByVal x As Long, ByVal y As Long) As Long
    'convert a 2d y coord to the corresponding isometric coord in a tile
    'starts from 0
    
    On Error Resume Next
    Dim toRet As Long, tX As Long, tY As Long, xx As Long, yy As Long
    toRet = 0
    
    tX = x
    tY = y
    
    xx = 62 + (tX) * 2 - (tY) * 2
    yy = (tX) + (tY)
                        
    getIsoY = yy \ 2

End Function

Public Sub tstToIsometric(Optional ByVal quality As Integer = 3): On Error Resume Next
'====================================================
'Takes a 32x32 tilemem, runs it through the rotation
'code and returns a 64x32 (62x32) tilemem.
'Unchanged rotation code moved from drawIsoTile.
'====================================================

    quality = 3
    ReDim IsoTile(128, 64) As Long
    Dim x As Long, y As Long, tX As Long, tY As Long
    Dim crColor As Long, crColor2 As Long, col As Long
    Dim r1 As Long, g1 As Long, b1 As Long
    Dim r2 As Long, g2 As Long, b2 As Long
    Dim ra As Long, ga As Long, ba As Long
    Dim tempx As Long, tempy As Long
    
    For x = 0 To 128
        For y = 0 To 64
            IsoTile(x, y) = -1
        Next y
    Next x
    
    'texture map into 128x64 isometric tile...
    For tX = 0 To 31 Step 1
        For tY = 0 To 31 Step 1
            crColor = tileMem(tX + 1, tY + 1)
            x = 62 + (tX) * 2 - (tY) * 2
            y = (tX) + (tY)
        
            crColor = tileMem(tX + 1, tY + 1)
            crColor2 = tileMem(tX + 2, tY + 1)
            If crColor <> -1 And crColor2 <> -1 And (quality = 1 Or quality = 2 Or quality = 3) Then
                r1 = red(crColor)
                g1 = green(crColor)
                b1 = blue(crColor)
            
                r2 = red(crColor2)
                g2 = green(crColor2)
                b2 = blue(crColor2)
                
                ra = (r2 - r1) \ 4
                ga = (g2 - g1) \ 4
                ba = (b2 - b1) \ 4
            
                For tempx = x To x + 4
                    col = RGB(r1, g1, b1)
                    
                    IsoTile(tempx, y) = col
                    r1 = r1 + ra
                    g1 = g1 + ga
                    b1 = b1 + ba
                Next tempx
            Else
                For tempx = x To x + 4
                    IsoTile(tempx, y) = crColor
                Next tempx
            End If
        Next tY
    Next tX
    
    'now scale down to 64x32 tile...
    Dim c1 As Long, c2 As Long, rr As Long, gg As Long, bb As Long
    
    ReDim smallTile(64, 32) As Long
    If quality = 3 Then
        'first shrink on x...
        ReDim medTile(64, 64) As Long
        
        Dim xx As Long, yy As Long
        xx = 0: yy = 0
        For x = 0 To 128 Step 2
            For y = 0 To 64
                c1 = IsoTile(x, y)
                c2 = IsoTile(x + 1, y)
                
                If c1 <> -1 And c2 <> -1 Then
                    r1 = red(c1): g1 = green(c1): b1 = blue(c1)
                    r2 = red(c2): g2 = green(c2): b2 = blue(c2)
                    rr = (r1 + r2) \ 2
                    gg = (g1 + g2) \ 2
                    bb = (b1 + b2) \ 2
                    medTile(xx, yy) = RGB(rr, gg, bb)
                Else
                    medTile(xx, yy) = c1
                End If
                yy = yy + 1
            Next y
            xx = xx + 1
            yy = 0
        Next x
        
        'now shrink on y...
        xx = 0: yy = 0
        For x = 0 To 64
            For y = 0 To 64 Step 2
                c1 = medTile(x, y)
                c2 = medTile(x, y + 1)
                
                If c1 <> -1 And c2 <> -1 Then
                    r1 = red(c1): g1 = green(c1): b1 = blue(c1)
                    r2 = red(c2): g2 = green(c2): b2 = blue(c2)
                    rr = (r1 + r2) \ 2
                    gg = (g1 + g2) \ 2
                    bb = (b1 + b2) \ 2
                    smallTile(xx, yy) = RGB(rr, gg, bb)
                Else
                    smallTile(xx, yy) = c1
                End If
                yy = yy + 1
            Next y
            xx = xx + 1
            yy = 0
        Next x
    Else
        xx = 0: yy = 0
        For x = 0 To 128 Step 2
            For y = 0 To 64 Step 2
                c1 = IsoTile(x, y)
                c2 = IsoTile(x + 1, y)
                
                If c1 <> -1 And c2 <> -1 And (quality = 2) Then
                    r1 = red(c1): g1 = green(c1): b1 = blue(c1)
                    r2 = red(c2): g2 = green(c2): b2 = blue(c2)
                    rr = (r1 + r2) \ 2
                    gg = (g1 + g2) \ 2
                    bb = (b1 + b2) \ 2
                    smallTile(xx, yy) = RGB(rr, gg, bb)
                Else
                    smallTile(xx, yy) = c1
                End If
                yy = yy + 1
            Next y
            xx = xx + 1
            yy = 0
        Next x
    End If

    'Store it in the buffer.
    For x = 0 To 64
        For y = 0 To 32
            bufTile(x, y) = smallTile(x, y)
        Next y
    Next x

    'We now have a 63x32 isometric tile, buftile, which we can either draw or use for the
    'mask.

End Sub

#End If
