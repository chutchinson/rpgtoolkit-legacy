Attribute VB_Name = "transFight"
'=========================================================================
'All contents copyright 2003, 2004, Christopher Matthews or Contributors
'All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
'Read LICENSE.txt for licensing info
'=========================================================================

'=========================================================================
' Interface with fight plugin
'=========================================================================

Option Explicit

'=========================================================================
' Integral variables
'=========================================================================
Public fightInProgress As Boolean   'fight going yn
Public numEne As Long               'number of enemies loaded
Public enemies(3) As String         'filenames of enemies loaded
Public canrun As Long               'can players run from fight?

'=========================================================================
' Read-only pointer to fightInProgress
'=========================================================================
Public Property Get isFightInProgress() As Boolean
    isFightInProgress = fightInProgress
End Property

'=========================================================================
' Run a fight if one is to occur
'=========================================================================
Public Sub fightTest()

    On Error Resume Next

    If isFightInProgress() Then
        'a fight is already going!
        Exit Sub
    End If

    Dim a As Long, b As Long
    If mainMem.fightgameYN = 0 Then
        'fighting has been enbabled in this game
        If boardList(activeBoardIndex).theData.fightingYN = 1 Then
            'Built in fighting engine
            If mainMem.fightType = 0 Then
                'Random fights
                a = Int(Rnd(1) * mainMem.chances) + 1
                If a = Int(mainMem.chances / 2) Then
                    If mainMem.fprgYN = 0 Then
                        'Built in fight
                        If mainMem.mainUseDayNight = 1 And boardList(activeBoardIndex).theData.BoardDayNight = 1 And boardList(activeBoardIndex).theData.BoardNightBattleOverride = 1 Then
                            If IsNight() Then
                                Call skilledFight(boardList(activeBoardIndex).theData.BoardSkillNight, boardList(activeBoardIndex).theData.BoardBackgroundNight$)
                            Else
                                Call skilledFight(boardList(activeBoardIndex).theData.boardskill, boardList(activeBoardIndex).theData.boardBackground$)
                            End If
                        Else
                            Call skilledFight(boardList(activeBoardIndex).theData.boardskill, boardList(activeBoardIndex).theData.boardBackground$)
                        End If
                    ElseIf mainMem.fprgYN = 1 Then
                        'RPGCode fight
                        Call runProgram(projectPath & prgPath & mainMem.fightPrg)
                    End If
                End If
            ElseIf mainMem.fightType = 1 Then
                'Planned fights
                a = stepsTaken
                b = Int(a / mainMem.chances)
                If (b * mainMem.chances) = a Then
                    If mainMem.fprgYN = 0 Then
                        'Built in fight
                        If mainMem.mainUseDayNight = 1 And boardList(activeBoardIndex).theData.BoardDayNight = 1 And boardList(activeBoardIndex).theData.BoardNightBattleOverride = 1 Then
                            If IsNight() Then
                                Call skilledFight(boardList(activeBoardIndex).theData.BoardSkillNight, boardList(activeBoardIndex).theData.BoardBackgroundNight$)
                            Else
                                Call skilledFight(boardList(activeBoardIndex).theData.boardskill, boardList(activeBoardIndex).theData.boardBackground$)
                            End If
                        Else
                            Call skilledFight(boardList(activeBoardIndex).theData.boardskill, boardList(activeBoardIndex).theData.boardBackground$)
                        End If
                    ElseIf mainMem.fprgYN = 1 Then
                        'RPGCode fight
                        Call runProgram(projectPath & prgPath & mainMem.fightPrg)
                    End If
                End If
            End If
        End If
    End If
End Sub

'=========================================================================
' Cause the enemy at partyIdx, fightIdx to attack
'=========================================================================
Public Sub enemyAttack(ByVal partyIdx As Long, ByVal fightIdx As Long)

    On Error Resume Next
    
    'Check that we have an enemy
    If Not parties(partyIdx).fighterList(fightIdx).isPlayer Then

        'Create a pointer
        Dim ene As TKEnemy
        ene = parties(partyIdx).fighterList(fightIdx).enemy
        
        'Check if there is an AI program
        If ene.eneRPGCode <> "" Then
            'Yep-- there is

            Dim a As Long, b As Long
            Dim indices(5) As Long

            'Create indices of living players
            For a = 0 To UBound(parties(PLAYER_PARTY).fighterList)
                Dim theHealth As Double
                theHealth = CBGetNumerical(parties(PLAYER_PARTY).fighterList(a).player.healthVar)
                If theHealth > 0 Then
                    b = b + 1
                    indices(b) = a
                End If
            Next a

            'Randomly choose one of them
            Dim toAttack As Long
            toAttack = indices(Int(Rnd(1) * b) + 1)
            
            'Set target, source, and run the program
            Call CBSetTarget(toAttack, TYPE_PLAYER)
            Call CBSetSource(fightIdx, TYPE_ENEMY)
            Call runProgram(projectPath & prgPath & ene.eneRPGCode, , False)
            
        Else
        
            'No AI program, use internal AI
            Call preformFightAI(ene.eneAI, partyIdx, fightIdx)
        
        End If
        
    End If

End Sub

'=========================================================================
' Inform the plugin of an attack
'=========================================================================
Public Sub fightInformAttack(ByVal sourcePartyIndex As Long, ByVal sourceFighterIndex As Long, ByVal targetPartyIndex As Long, ByVal targetFighterIndex As Long, ByVal targetHPLost As Long, ByVal targetSMPLost As Long)

    On Error Resume Next
    
    If fightInProgress Then
        'yup-- send it
        If mainMem.fightPlugin <> "" Then
            Dim code As Long
            code = INFORM_SOURCE_ATTACK
            
            Dim plugName As String
            plugName = PakLocate(projectPath$ + plugPath$ + mainMem.fightPlugin)
            
            If isVBPlugin(plugName) Then
                Call VBPlugin(plugName).fightInform(sourcePartyIndex, sourceFighterIndex, targetPartyIndex, targetFighterIndex, 0, 0, targetHPLost, targetSMPLost, "", code)
            Else
                Call PLUGFightInform(plugName, sourcePartyIndex, sourceFighterIndex, targetPartyIndex, targetFighterIndex, 0, 0, targetHPLost, targetSMPLost, "", code)
            End If

        End If
    End If
End Sub

'=========================================================================
' Inform the plugin of a stat being removed
'=========================================================================
Public Sub fightInformRemoveStat(ByVal targetPartyIndex As Long, ByVal targetFighterIndex As Long, ByVal amountLost As Long, ByVal toSMP As Boolean, Optional ByVal msg As String = "")

    On Error Resume Next
    
    If fightInProgress Then
        'yup-- send it
        If mainMem.fightPlugin <> "" Then
            Dim code As Long
            Dim plugName As String
            plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
            
            If toSMP Then
                code = INFORM_REMOVE_HP
                
                If isVBPlugin(plugName) Then
                    Call VBPlugin(plugName).fightInform(-1, -1, targetPartyIndex, targetFighterIndex, 0, 0, amountLost, 0, msg, code)
                Else
                    Call PLUGFightInform(plugName, -1, -1, targetPartyIndex, targetFighterIndex, 0, 0, amountLost, 0, msg, code)
                End If
                
            Else
                code = INFORM_REMOVE_SMP
                If isVBPlugin(plugName) Then
                    Call VBPlugin(plugName).fightInform(-1, -1, targetPartyIndex, targetFighterIndex, 0, 0, amountLost, 0, msg, code)
                Else
                    Call PLUGFightInform(plugName, -1, -1, targetPartyIndex, targetFighterIndex, 0, 0, amountLost, 0, msg, code)
                End If
            End If
        End If
    End If
End Sub

'=========================================================================
' Inform the plugin of an item being used
'=========================================================================
Public Sub fightInformItemUse(ByVal sourcePartyIndex As Long, ByVal sourceFighterIndex As Long, ByVal targetPartyIndex As Long, ByVal targetFighterIndex As Long, ByVal targetHPLost As Long, ByVal targetSMPLost As Long, ByVal itemFile As String)

    On Error Resume Next
    
    If fightInProgress Then
        'yup-- send it
        If mainMem.fightPlugin <> "" Then
            Const code = INFORM_SOURCE_ITEM
            Dim plugName As String
            plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
            If isVBPlugin(plugName) Then
                Call VBPlugin(plugName).fightInform(sourcePartyIndex, sourceFighterIndex, targetPartyIndex, targetFighterIndex, 0, 0, targetHPLost, targetSMPLost, itemFile, code)
            Else
                Call PLUGFightInform(plugName, sourcePartyIndex, sourceFighterIndex, targetPartyIndex, targetFighterIndex, 0, 0, targetHPLost, targetSMPLost, itemFile, code)
            End If
        End If
    End If
End Sub

'=========================================================================
' Inform the plugin of a special move being used
'=========================================================================
Public Sub fightInformSpecialMove(ByVal sourcePartyIndex As Long, ByVal sourceFighterIndex As Long, ByVal targetPartyIndex As Long, ByVal targetFighterIndex As Long, ByVal sourceSMPLost As Long, ByVal targetHPLost As Long, ByVal targetSMPLost As Long, ByVal moveFile As String)

    On Error Resume Next
    
    If fightInProgress Then
        'yup-- send it
        If mainMem.fightPlugin <> "" Then
            Dim code As Long
            code = INFORM_SOURCE_SMP
            Dim plugName As String
            plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
            
            If isVBPlugin(plugName) Then
                Call VBPlugin(plugName).fightInform(sourcePartyIndex, sourceFighterIndex, targetPartyIndex, targetFighterIndex, 0, sourceSMPLost, targetHPLost, targetSMPLost, moveFile, code)
            Else
                Call PLUGFightInform(plugName, sourcePartyIndex, sourceFighterIndex, targetPartyIndex, targetFighterIndex, 0, sourceSMPLost, targetHPLost, targetSMPLost, moveFile, code)
            End If
            
        End If
    End If
End Sub

'=========================================================================
' Inform the plugin that a party was defeated
'=========================================================================
Public Sub fightInformPartyDefeated(ByVal sourcePartyIndex As Long)

    On Error Resume Next

    If fightInProgress Then
        'yup-- send it
        If mainMem.fightPlugin <> "" Then
            Dim code As Long
            code = INFORM_SOURCE_PARTY_DEFEATED
            Dim plugName As String
            plugName = PakLocate(projectPath$ + plugPath$ + mainMem.fightPlugin)
            If isVBPlugin(plugName) Then
                Call VBPlugin(plugName).fightInform(sourcePartyIndex, -1, 0, 0, 0, 0, 0, 0, "", code)
            Else
                Call PLUGFightInform(plugName, sourcePartyIndex, -1, 0, 0, 0, 0, 0, 0, "", code)
            End If
        End If
    End If

End Sub

'=========================================================================
' Inform the plugin that a player is ready to attack
'=========================================================================
Public Sub fightInformCharge(ByVal partyIdx As Long, ByVal fighterIdx As Long)

    On Error Resume Next
    
    If fightInProgress Then
        'yup-- send it
        If mainMem.fightPlugin <> "" Then
            Dim code As Long
            code = INFORM_SOURCE_CHARGED
            Dim plugName As String
            plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
            If isVBPlugin(plugName) Then
                Call VBPlugin(plugName).fightInform(partyIdx, fighterIdx, -1, -1, 0, 0, 0, 0, "", code)
            Else
                Call PLUGFightInform(plugName, partyIdx, fighterIdx, -1, -1, 0, 0, 0, 0, "", code)
            End If
        End If
    End If
End Sub

'=========================================================================
' Increment charge bars
'=========================================================================
Public Sub fightTick()

    On Error Resume Next

    Dim t As Long
    Dim u As Long
    Dim s As Long
    Dim status As TKStatusEffect
    
    'first increment ticks...
    For t = 0 To UBound(parties) - 1
        For u = 0 To UBound(parties(t).fighterList) - 1
            If parties(t).fighterList(u).chargeCounter <= parties(t).fighterList(u).maxChargeTime Then
                'check if the fighter has a status effect applied that changes the charge time...
                If Not (parties(t).fighterList(u).freezeCharge) And (getPartyMemberHP(t, u) > 0) Then
                    parties(t).fighterList(u).chargeCounter = parties(t).fighterList(u).chargeCounter + 1
                End If
            Else
                'fighter is charged...
                'tell the plugin that the player is charged...
                If getPartyMemberHP(t, u) > 0 Then
                    If Not (parties(t).fighterList(u).isPlayer) Then
                        'this is an enemy.
                        'check for enemy status effects...
                        For s = 0 To UBound(parties(t).fighterList(u).enemy.status)
                            If parties(t).fighterList(u).enemy.status(s).roundsLeft > 0 And _
                                parties(t).fighterList(u).enemy.status(s).statusFile <> "" Then
                                Call openStatus(projectPath$ + statusPath$ + parties(t).fighterList(u).enemy.status(s).statusFile, status)
                                
                                'now apply the effects of the status...
                                Call invokeStatus(t, u, status, parties(t).fighterList(u).enemy.status(s).statusFile)
                                
                                parties(t).fighterList(u).enemy.status(s).roundsLeft = parties(t).fighterList(u).enemy.status(s).roundsLeft - 1
                                If parties(t).fighterList(u).enemy.status(s).roundsLeft = 0 Then
                                    parties(t).fighterList(u).enemy.status(s).statusFile = ""
                                End If
                            End If
                        Next s
                        
                        'the enemy now makes a move...
                        Call fightInformCharge(t, u)
                        Call enemyAttack(t, u)
                        'reset the counter...
                        parties(t).fighterList(u).chargeCounter = 0
                    Else
                        'this is a player.
                        
                        'check for player status effects...
                        For s = 0 To UBound(parties(t).fighterList(u).player.status)
                            If parties(t).fighterList(u).player.status(s).roundsLeft > 0 And _
                                parties(t).fighterList(u).player.status(s).statusFile <> "" Then
                                Call openStatus(projectPath$ + statusPath$ + parties(t).fighterList(u).player.status(s).statusFile, status)
                                
                                'now apply the effects of the status...
                                Call invokeStatus(t, u, status, parties(t).fighterList(u).player.status(s).statusFile)
                                
                                parties(t).fighterList(u).player.status(s).roundsLeft = parties(t).fighterList(u).player.status(s).roundsLeft - 1
                                If parties(t).fighterList(u).player.status(s).roundsLeft = 0 Then
                                    parties(t).fighterList(u).player.status(s).statusFile = ""
                                End If
                            End If
                        Next s
                        
                        If Not (parties(t).fighterList(u).freezeCharge) Then
                            'now lock the player from charging again...
                            parties(t).fighterList(u).freezeCharge = True
                            'tell the plugin that the plyer is charged...
                            Call fightInformCharge(t, u)
                        End If
                    End If
                End If
            End If
        Next u
    Next t
    
    'check for the end of the fight...
    If isPartyDefeated(PLAYER_PARTY) Then
        Call fightInformPartyDefeated(PLAYER_PARTY)
    ElseIf isPartyDefeated(ENEMY_PARTY) Then
        Call fightInformPartyDefeated(ENEMY_PARTY)
    End If
    
    DoEvents

End Sub

'========================================================================
' Load the enemies passed in
'=========================================================================
Public Sub loadEnemies(ByRef eneList() As String, ByVal num As Long)
    On Error Resume Next
    Dim t As Long
    For t = 0 To num - 1
        Call openEnemy(projectPath$ + enePath$ + eneList(t), enemyMem(t))
    Next t
End Sub

'=========================================================================
' Reward the players
'=========================================================================
Public Sub rewardPlayers(ByVal numEnemies As Long, ByVal rewardPrg As String)
    On Error Resume Next
    Dim t As Long
    Dim exp As Long
    Dim gp As Long
    For t = 0 To numEnemies - 1
        exp = exp + enemyMem(t).eneExp
        gp = gp + enemyMem(t).eneGP
    Next t
    
    Dim retval As RPGCODE_RETURN
    Dim thePrg As RPGCodeProgram
    Call InitRPGCodeProcess(thePrg)
    thePrg.boardNum = -1     'not attached to the board
    
    If exp > 0 Or gp > 0 Then
        'give players experience...
        Call CanvasGetScreen(cnvRPGCodeScreen)
        lineNum = 1
        If exp > 0 Then
            Call AddToMsgBox("Players gained" + str$(exp) + " experience!", thePrg)
        End If
        If gp > 0 Then
            Call AddToMsgBox("Players gained" + str$(gp) + " GP!", thePrg)
        End If
        Call renderRPGCodeScreen
        Call WaitForKey
    End If
    
    For t = 0 To UBound(playerListAr)
        If playerListAr(t) <> "" Then
            Call giveExperience(exp, playerMem(t))
        End If
    Next t
    
    GPCount = GPCount + gp
    
    'run rpgcode program, if any
    If rewardPrg <> "" Then
        Call runProgram(projectPath$ + prgPath$ + rewardPrg)
    End If
End Sub

'=========================================================================
' Run if the players lose
'=========================================================================
Public Sub gameOver()
    On Error Resume Next
    
    Dim retval As RPGCODE_RETURN
    Dim theProgram As RPGCodeProgram
    Call InitRPGCodeProcess(theProgram)
    theProgram.boardNum = -1
    Call CanvasGetScreen(cnvRPGCodeScreen)
    
    If mainMem.gameOverPrg = "" Then
        Call DXClearScreen(0)
        Call DXDrawText(1, 1, "Game Over...", "Arial", 48, RGB(255, 255, 255), 1, 0, 0, 0, 0)
        Call WaitForKey
    Else
        Call runProgram(projectPath & prgPath & mainMem.gameOverPrg)
    End If
    Call ResetRPG(theProgram)
End Sub

'=========================================================================
' Begin a fight against the enemies passed in on the background passed in
'=========================================================================
Public Sub runFight(ByRef eneList() As String, ByVal num As Long, ByVal bkg As String)

    On Error Resume Next
       
    If fightInProgress Then Exit Sub
    
    'flush out the keyboard movement buffer
    Call FlushKB
    
    fightInProgress = True
    
    'load enemies
    Call loadEnemies(eneList, num)
    
    canrun = 1
    Dim t As Long, cnt As Long
    'create enemy party...
    Dim strRunProgram As String
    Dim strRewardProgram As String
    ReDim eParty(num) As TKEnemy
    For t = 0 To num - 1
        eParty(t) = enemyMem(t)
        If enemyMem(t).eneRunPrg <> "" Then
            strRunProgram = enemyMem(t).eneRunPrg
        End If
        If enemyMem(t).eneRun = 0 Then
            canrun = 0
        End If
        If enemyMem(t).eneWinPrg <> "" Then
            strRewardProgram = enemyMem(t).eneWinPrg
        End If
    Next t
    Call CreateEnemyParty(parties(0), eParty)
    
    'create player party...
    cnt = 0
    For t = 0 To UBound(playerMem)
        If playerFile(t) <> "" Then
            cnt = cnt + 1
        End If
    Next t
    ReDim pParty(cnt) As TKPlayer
    cnt = 0
    For t = 0 To UBound(playerMem)
        If playerFile(t) <> "" Then
            pParty(cnt) = playerMem(t)
            cnt = cnt + 1
        End If
    Next t
    Call CreatePlayerParty(parties(1), pParty, inv, 0)
    
    'play fight music...
    Dim back As TKBackground
    Call openBackground(projectPath$ + bkgPath$ + bkg, back)
    Dim oldsong As String
    oldsong = musicPlaying
    boardList(activeBoardIndex).theData.boardMusic = back.bkgMusic
    Call checkMusic(True)
           
    If mainMem.fightPlugin <> "" Then
        Dim aa As Long
        Dim plugName As String
        plugName = PakLocate(projectPath$ + plugPath$ + mainMem.fightPlugin)
        
        If isVBPlugin(plugName) Then
            aa = VBPlugin(plugName).plugType(PT_FIGHT)
        Else
            aa = plugType(plugName, PT_FIGHT)
        End If
        
        If aa = 1 Then
            Dim a As Long
            
            If isVBPlugin(plugName) Then
                a = VBPlugin(plugName).fight(num, -1, bkg, canrun)
            Else
                a = PLUGFight(plugName, num, -1, bkg, canrun)
            End If
            
            Select Case a
                Case FIGHT_RUN_AUTO:
                    'run the run away program...
                    Call runProgram(projectPath$ + prgPath$ + strRunProgram)
                Case FIGHT_RUN_MANUAL:
                    'no need to run anything...
                Case FIGHT_WON_AUTO:
                    Call rewardPlayers(num, strRewardProgram)
                    'give players rewards...
                Case FIGHT_WON_MANUAL:
                    'no need to do anything...
                Case FIGHT_LOST:
                    'do a game over...
                    Call gameOver
            End Select
        End If
    End If
    boardList(activeBoardIndex).theData.boardMusic = oldsong
    Call checkMusic(True)

    fightInProgress = False
    
    Exit Sub
'Begin error handling code:
errorhandler:
    Call HandleError
    Resume Next
End Sub

'=========================================================================
' Randomly return an enemy of the skill passed in
'=========================================================================
Function getEnemy(ByVal skill As Long) As String

    On Error Resume Next
    
    'count the possibilities:
    Dim total As Long, t As Long
    total = 0
    For t = 0 To UBound(mainMem.skill)
        If mainMem.skill(t) = skill Then total = total + 1
    Next t
    If total = 0 Then
        getEnemy = ""
        Exit Function
    End If
    
    'Now get the nth enemy of that skill:
    Dim whichOne As Long, thisOne As Long
    whichOne = Int(Rnd(1) * total) + 1
    thisOne = 0
    For t = 0 To UBound(mainMem.skill)
        If mainMem.skill(t) = skill Then
            thisOne = thisOne + 1
            If thisOne = whichOne Then
                Dim file As String
                file = mainMem.enemy$(t)
                getEnemy = file
                Exit Function
            End If
        End If
    Next t
    getEnemy = ""
End Function

'=========================================================================
' Initiate a fight of the skill passed in
'=========================================================================
Public Sub skilledFight(ByVal skill As Long, ByVal bkg As String)
    
    On Error Resume Next

    Dim t As Long
    
    numEne = Int(Rnd(1) * 4) + 1
    For t = 0 To numEne - 1
        enemies(t) = getEnemy(skill)
        If enemies(t) = "" Then
            Call MBox(LoadStringLoc(829, "No Enemies of skill ") + str$(skill) + LoadStringLoc(830, " found!!!"), LoadStringLoc(831, "Can't Fight"), 0, menuColor, projectPath$ + bmpPath$ + mainMem.skinWindow$, projectPath$ + bmpPath$ + mainMem.skinButton$)
            Exit Sub
        End If
    Next t
    Call runFight(enemies, numEne, bkg)
End Sub

'=========================================================================
' Initiate the fight plugin
'=========================================================================
Public Sub startFightPlugin()
    On Error Resume Next
    If mainMem.fightPlugin <> "" Then
        Dim plugName As String
        plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
        If Not isVBPlugin(plugName) Then
            Call PLUGBegin(plugName)
        Else
            Call VBPlugin(plugName).Initialize
        End If
    End If
End Sub

'=========================================================================
' Terminate the fight plugin
'=========================================================================
Public Sub stopFightPlugin()
    On Error Resume Next
    If mainMem.fightPlugin <> "" Then
        Dim plugName As String
        plugName = PakLocate(projectPath & plugPath & mainMem.fightPlugin)
        If isVBPlugin(plugName) Then
            Call VBPlugin(plugName).Terminate
        Else
            Call PLUGEnd(plugName)
        End If
    End If
End Sub
