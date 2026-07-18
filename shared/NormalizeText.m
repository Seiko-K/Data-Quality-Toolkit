// ============================================
// NormalizeText.m
//
// Reusable shared function for text normalization.
//
// This function converts any input value to text,
// removes leading/trailing whitespace,
// and converts empty strings to null.
//
// 再利用可能なテキスト正規化関数です。
//
// 入力値を文字列へ変換し、
// 前後の空白を削除し、
// 空文字を null に統一します。
// ============================================

(value as any) as nullable text =>

let

    // Convert the input value to text.
    // 入力値を文字列へ変換する。
    AsText =
        if value = null then
            null
        else
            Text.From(value),

    // Remove leading and trailing whitespace.
    // 前後の余計な空白を削除する。
    Trimmed =
        if AsText = null then
            null
        else
            Text.Trim(AsText),

    // Convert empty strings to null.
    // 空文字を欠損値(null)へ統一する。
    Normalized =
        if Trimmed = "" then
            null
        else
            Trimmed

in

    Normalized