Attribute VB_Name = "Shop"
'All contents copyright 2003, 2004, Christopher Matthews or Contributors
'All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
'Read LICENSE.txt for licensing info

Option Explicit

Public itemsforsale(500) As String  'filenames of 500 items to sell.
Public itemMap(500) As Long

Public Sub shopGiveItems(ByVal file As String, ByVal num As Long)
    'add num items as defined by file$

    On Error Resume Next

    Dim n As String
    n = getItemName(projectPath & itmPath & file)
    file = addext(file, ".itm")
    Dim theOne As Long, t As Long
    theOne = -1
    With inv
        For t = 0 To UBound(.item)
            If UCase(.item(t).file) = UCase(file) Then theOne = t
        Next t
        If theOne <> -1 Then
            .item(theOne).number = .item(theOne).number + num
        Else
            theOne = -1
            For t = 0 To UBound(.item)
                If .item(t).file = "" Then
                    theOne = t
                    Exit For
                End If
            Next t
            If theOne <> -1 Then
                With .item(theOne)
                    .file = file
                    .number = num
                    .handle = n
                End With
            End If
        End If
    End With

End Sub

Public Sub shopTakeItems(ByVal file As String, ByVal num As Long)
    'take num items as defined by file$

    On Error Resume Next
    Dim n As String
    n = getItemName(projectPath & itmPath & file)
    file = addext(file, ".itm")
    Dim theOne As Long, t As Long
    theOne = -1
    With inv
        For t = 0 To UBound(.item)
            If UCase(.item(t).file) = UCase(file) Then theOne = t
        Next t
        If theOne <> -1 Then
            With .item(theOne)
                .number = .number - num
                If .number <= 0 Then
                    .file = ""
                    .number = 0
                    .handle = ""
                End If
            End With
        End If
    End With

End Sub
