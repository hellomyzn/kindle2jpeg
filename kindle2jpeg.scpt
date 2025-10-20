on run argv
    -- デフォルト値
    set bookName to "Untitled Bookname"
    set pageCount to 0

    -- 引数パース
    set i to 1
    repeat while i ≤ (count of argv)
        set a to item i of argv as text
        if a is "-b" or a is "--book" then
            set bookName to item (i + 1) of argv as text
            set i to i + 1
        else if a is "-p" or a is "--pages" then
            try
                set pageCount to (item (i + 1) of argv) as integer
                set i to i + 1
            on error
                display dialog "ERROR: --pages には数値を指定してください。" buttons {"OK"} default button "OK"
                return
            end try
        else if a is "-h" or a is "--help" then
            set usage to "Usage: osascript KindleShots.applescript [options]

Options:
  -b, --book <name>     本の名前
  -p, --pages <int>     撮影するページ数
  -h, --help            このヘルプを表示

Example:
  osascript KindleShots.applescript -b 'Deep Work' -p 25"
            do shell script "echo " & quoted form of usage
            return
        end if
        set i to i + 1
    end repeat

    -- 基本設定
    set saveToLocation to "/Users/<USERNAME>/screen shots/KindleScreenshots/"
    set screenshotRegion to {84, 88, 678, 952}
    set windowPosition to {10, 60}
    set windowSize to {827, 980}
    set pageKeyCode to 125

    -- 保存フォルダを作成
    set bookFolderPath to saveToLocation & bookName & "/"
    try
        do shell script "mkdir -p " & quoted form of bookFolderPath
    on error errMsg
        display dialog "保存フォルダの作成に失敗しました: " & errMsg buttons {"OK"} default button "OK"
        return
    end try

    set baseFilePath to bookFolderPath & bookName

    -- Kindle 起動・前面化
    try
        tell application "Amazon Kindle"
            if it is not running then
                launch
                delay 3.0
            end if
            activate
        end tell
        delay 0.5
    on error errMsg
        display dialog "Kindleアプリが見つかりません: " & errMsg buttons {"OK"} default button "OK"
        return
    end try

    -- ウィンドウ位置・サイズ設定
    try
        tell application "System Events"
            tell process "Amazon Kindle"
                tell window 1
                    set position to windowPosition
                    set size to windowSize
                end tell
            end tell
        end tell
        delay 0.5
    on error errMsg
        display dialog "ウィンドウ操作に失敗しました: " & errMsg buttons {"OK"} default button "OK"
    end try

    -- ページごとにスクリーンショット
    repeat with i from 1 to pageCount
        tell application "Amazon Kindle" to activate
        delay 0.2

        set imgPath to baseFilePath & "_Page" & i & ".jpg"
        set shellCMD to "screencapture -R" & (item 1 of screenshotRegion) & "," & (item 2 of screenshotRegion) & "," & (item 3 of screenshotRegion) & "," & (item 4 of screenshotRegion) & " -t jpg " & quoted form of imgPath
        try
            do shell script shellCMD
        on error errMsg
            display dialog "スクリーンショットに失敗しました: " & errMsg buttons {"OK"} default button "OK"
            return
        end try

        delay 1.0
        tell application "System Events" to key code pageKeyCode
        delay 1.0
    end repeat

    display dialog "スクリーンショット完了: " & bookFolderPath buttons {"OK"} default button "OK"
end run
