# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

#Requires -Modules @{ ModuleName="PSReadLine"; ModuleVersion="2.2.6" }
#Requires -Modules @{ ModuleName="CompletionPredictor"; ModuleVersion="0.1.0" }

using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Set-PSReadLineOption -HistoryNoDuplicates:$true -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

Set-PSReadLineOption -PredictionViewStyle InlineView

Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Script
Set-PSReadLineOption -BellStyle None

Set-PSReadLineOption -Colors @{
  "Comment"                = "#566573"
  "Command"                = "#FF0000"
  "ContinuationPrompt"     = "#D5D8DC"
  "Emphasis"               = "#27AE60"
  "Keyword"                = "#52BE80"
  "ListPrediction"         = "#1F618D"
  "ListPredictionSelected" = "#D35400"
  "Member"                 = "#FFFFFF"
  "Number"                 = "#E74C3C"
  "Operator"               = "#E74C3C"
  "Parameter"              = "#3498DB"
  "String"                 = "#28B463"
  "Type"                   = "#DE3163"
  "Variable"               = "#E0115F"
}

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+Shift+a, Ctrl+Shift+A -Function SelectAll
Set-PSReadLineKeyHandler -Chord Ctrl+Shift+l, Ctrl+Shift+L -Function RevertLine
Set-PSReadLineKeyHandler -Chord Ctrl+Shift+j, Ctrl+Shift+J -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+Shift+l, Ctrl+Shift+L -Function NextWord
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function DeleteLine
Set-PSReadLineKeyHandler -Chord Ctrl+d, Ctrl+c -Function CaptureScreen
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord

Set-PSReadLineKeyHandler -Key '"', "'" `
  -BriefDescription SmartInsertQuote `
  -LongDescription "Insert paired quotes if not already on a quote" `
  -ScriptBlock {
  param($key, $arg)

  $quote = $key.KeyChar

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  # If text is selected, just quote it without any smarts
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    return
  }

  $ast = $null
  $tokens = $null
  $parseErrors = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

  function FindToken {
    param($tokens, $cursor)

    foreach ($token in $tokens) {
      if ($cursor -lt $token.Extent.StartOffset) { continue }
      if ($cursor -lt $token.Extent.EndOffset) {
        $result = $token
        $token = $token -as [StringExpandableToken]
        if ($token) {
          $nested = FindToken $token.NestedTokens $cursor
          if ($nested) { $result = $nested }
        }

        return $result
      }
    }
    return $null
  }

  $token = FindToken $tokens $cursor

  # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
  if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
    # If we're at the start of the string, assume we're inserting a new string
    if ($token.Extent.StartOffset -eq $cursor) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
      return
    }

    # If we're at the end of the string, move over the closing quote if present.
    if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
      return
    }
  }

  if ($null -eq $token -or
    $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
    if ($line[0..$cursor].Where{ $_ -eq $quote }.Count % 2 -eq 1) {
      # Odd number of quotes before the cursor, insert a single quote
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
    }
    else {
      # Insert matching quotes, move cursor to be in between the quotes
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    return
  }

  # If cursor is at the start of a token, enclose it in quotes.
  if ($token.Extent.StartOffset -eq $cursor) {
    if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or
      $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
      $end = $token.Extent.EndOffset
      $len = $end - $cursor
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
      return
    }
  }

  # We failed to be smart, so just insert a single quote
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key '(', '{', '[' `
  -BriefDescription InsertPairedBraces `
  -LongDescription "Insert matching braces" `
  -ScriptBlock {
  param($key, $arg)

  $closeChar = switch ($key.KeyChar) {
    <#case#> '(' { [char]')'; break }
    <#case#> '{' { [char]'}'; break }
    <#case#> '[' { [char]']'; break }
    <#case#> '"' { [char]'"'; break }
    <#case#> "'" { [char]"'"; break }
  }

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($selectionStart -ne -1) {
    # Text is selected, wrap it in brackets
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  }
  else {
    # No text is selected, insert a pair
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  }
}

Set-PSReadLineKeyHandler -Key ')', ']', '}' `
  -BriefDescription SmartCloseBraces `
  -LongDescription "Insert closing brace or skip" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($line[$cursor] -eq $key.KeyChar) {
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
  }
}

Set-PSReadLineKeyHandler -Key Backspace `
  -BriefDescription SmartBackspace `
  -LongDescription "Delete previous character or matching quotes/parens/braces" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($cursor -gt 0) {
    $toMatch = $null
    if ($cursor -lt $line.Length) {
      switch ($line[$cursor]) {
        <#case#> '"' { $toMatch = '"'; break }
        <#case#> "'" { $toMatch = "'"; break }
        <#case#> ')' { $toMatch = '('; break }
        <#case#> ']' { $toMatch = '['; break }
        <#case#> '}' { $toMatch = '{'; break }
      }
    }

    if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
    }
    else {
      [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
    }
  }
}