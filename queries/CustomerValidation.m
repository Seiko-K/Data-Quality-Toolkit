let
    // Define the input CSV file path.
    // 入力する顧客マスタCSVのファイルパスを定義する。
    CustomerFilePath =
        "samples/customer_master.csv",

    // Load the customer master CSV file as UTF-8 data.
    // 顧客マスタCSVをUTF-8形式で読み込む。
    Source =
        Csv.Document(
            File.Contents(CustomerFilePath),
            [
                Delimiter = ",",
                Encoding = 65001,
                QuoteStyle = QuoteStyle.Csv
            ]
        ),

    // Promote the first row to column headers.
    // CSVの先頭行を列見出しとして設定する。
    Headers =
        Table.PromoteHeaders(
            Source,
            [PromoteAllScalars = true]
        ),

    // Keep only the columns required for customer validation.
    // 顧客チェックに必要な列だけを残す。
    // Missing columns are created with null values instead of causing an error.
    // 必要な列が存在しない場合は、エラーではなくnull列として補完する。
    SelectedColumns =
        Table.SelectColumns(
            Headers,
            {"CustomerID", "Name", "Email"},
            MissingField.UseNull
        ),
    // Normalize the required customer fields by converting values to text,
    // trimming leading and trailing whitespace, and converting empty strings to null.
    // 顧客チェックに必要な各項目を文字列へ変換し、
    // 前後の空白を削除したうえで、空文字をnullへ統一する。
    Normalized =
        Table.TransformColumns(
            SelectedColumns,
            {
                {
                    "CustomerID",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Name",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Email",
                    each NormalizeText(_),
                    type nullable text
                }
            }
        ),

    // Add a temporary row number to preserve the original CSV order.
    // 最後まで元のCSVの行順を維持するため、一時的な行番号を追加する。
    AddedRowOrder =
        Table.AddIndexColumn(
            Normalized,
            "__RowOrder",
            1,
            1,
            Int64.Type
        ),

    // Create a lowercase email value for case-insensitive duplicate detection.
    // 大文字・小文字を区別せずメール重複を検出するため、小文字版メールを作成する。
    AddedNormalizedEmail =
        Table.AddColumn(
            AddedRowOrder,
            "__NormalizedEmail",
            each
                if [Email] = null
                then null
                else Text.Lower([Email]),
            type nullable text
        ),

    // Count how many times each non-empty CustomerID appears.
    // 空欄ではないCustomerIDごとに登録件数を数える。
    CustomerIDCounts =
        Table.Group(
            Table.SelectRows(
                AddedNormalizedEmail,
                each [CustomerID] <> null
            ),
            {"CustomerID"},
            {
                {
                    "__CustomerIDCount",
                    each Table.RowCount(_),
                    Int64.Type
                }
            }
        ),

    // Attach the CustomerID count to each original row.
    // CustomerIDごとの件数を元データの各行へ結合する。
    MergedCustomerIDCounts =
        Table.NestedJoin(
            AddedNormalizedEmail,
            {"CustomerID"},
            CustomerIDCounts,
            {"CustomerID"},
            "__CustomerIDMatch",
            JoinKind.LeftOuter
        ),

    // Expand the CustomerID count column.
    // 結合したCustomerID件数を通常の列として展開する。
    ExpandedCustomerIDCounts =
        Table.ExpandTableColumn(
            MergedCustomerIDCounts,
            "__CustomerIDMatch",
            {"__CustomerIDCount"},
            {"__CustomerIDCount"}
        ),

    // Count how many times each non-empty normalized email appears.
    // 空欄ではないメールアドレスごとに登録件数を数える。
    EmailCounts =
        Table.Group(
            Table.SelectRows(
                ExpandedCustomerIDCounts,
                each [__NormalizedEmail] <> null
            ),
            {"__NormalizedEmail"},
            {
                {
                    "__EmailCount",
                    each Table.RowCount(_),
                    Int64.Type
                }
            }
        ),

    // Attach the email count to each original row.
    // メールアドレスごとの件数を元データの各行へ結合する。
    MergedEmailCounts =
        Table.NestedJoin(
            ExpandedCustomerIDCounts,
            {"__NormalizedEmail"},
            EmailCounts,
            {"__NormalizedEmail"},
            "__EmailMatch",
            JoinKind.LeftOuter
        ),

    // Expand the email count column.
    // 結合したメール件数を通常の列として展開する。
    ExpandedEmailCounts =
        Table.ExpandTableColumn(
            MergedEmailCounts,
            "__EmailMatch",
            {"__EmailCount"},
            {"__EmailCount"}
        ),

    // Count records where CustomerID, Name, and Email are all identical.
    // CustomerID・Name・Emailがすべて同じ完全重複レコードを数える。
    ExactDuplicateCounts =
        Table.Group(
            Table.SelectRows(
                ExpandedEmailCounts,
                each
                    [CustomerID] <> null
                    and [Name] <> null
                    and [__NormalizedEmail] <> null
            ),
            {"CustomerID", "Name", "__NormalizedEmail"},
            {
                {
                    "__ExactDuplicateCount",
                    each Table.RowCount(_),
                    Int64.Type
                }
            }
        ),

    // Attach the exact duplicate count to each original row.
    // 完全重複の件数を元データの各行へ結合する。
    MergedExactDuplicateCounts =
        Table.NestedJoin(
            ExpandedEmailCounts,
            {"CustomerID", "Name", "__NormalizedEmail"},
            ExactDuplicateCounts,
            {"CustomerID", "Name", "__NormalizedEmail"},
            "__ExactDuplicateMatch",
            JoinKind.LeftOuter
        ),

    // Expand the exact duplicate count column.
    // 結合した完全重複件数を通常の列として展開する。
    ExpandedExactDuplicateCounts =
        Table.ExpandTableColumn(
            MergedExactDuplicateCounts,
            "__ExactDuplicateMatch",
            {"__ExactDuplicateCount"},
            {"__ExactDuplicateCount"}
        ),

    // Flag records with a missing CustomerID.
    // CustomerIDが空欄のレコードを検出する。
    AddedMissingCustomerID =
        Table.AddColumn(
            ExpandedExactDuplicateCounts,
            "MissingCustomerID",
            each [CustomerID] = null,
            type logical
        ),

    // Flag records with a missing customer name.
    // 顧客名が空欄のレコードを検出する。
    AddedMissingName =
        Table.AddColumn(
            AddedMissingCustomerID,
            "MissingName",
            each [Name] = null,
            type logical
        ),

    // Flag records with a missing email address.
    // メールアドレスが空欄のレコードを検出する。
    AddedMissingEmail =
        Table.AddColumn(
            AddedMissingName,
            "MissingEmail",
            each [Email] = null,
            type logical
        ),

    // Flag CustomerIDs that appear more than once.
    // 同じCustomerIDが複数行に存在する場合、重複として検出する。
    AddedDuplicateCustomerID =
        Table.AddColumn(
            AddedMissingEmail,
            "IsDuplicateCustomerID",
            each
                (
                    if [__CustomerIDCount] = null
                    then 0
                    else [__CustomerIDCount]
                ) > 1,
            type logical
        ),

    // Flag email addresses that appear more than once.
    // 同じメールアドレスが複数行に存在する場合、重複として検出する。
    AddedDuplicateEmail =
        Table.AddColumn(
            AddedDuplicateCustomerID,
            "IsDuplicateEmail",
            each
                (
                    if [__EmailCount] = null
                    then 0
                    else [__EmailCount]
                ) > 1,
            type logical
        ),

    // Flag records where CustomerID, Name, and Email are all identical.
    // CustomerID・Name・Emailがすべて一致する完全重複レコードを検出する。
    AddedExactDuplicate =
        Table.AddColumn(
            AddedDuplicateEmail,
            "IsExactDuplicate",
            each
                (
                    if [__ExactDuplicateCount] = null
                    then 0
                    else [__ExactDuplicateCount]
                ) > 1,
            type logical
        ),

    // Set the overall validation status.
    // いずれかの問題がある場合はReview、問題がなければOKを設定する。
    AddedValidationStatus =
        Table.AddColumn(
            AddedExactDuplicate,
            "ValidationStatus",
            each
                if
                    [MissingCustomerID]
                    or [MissingName]
                    or [MissingEmail]
                    or [IsDuplicateCustomerID]
                    or [IsDuplicateEmail]
                    or [IsExactDuplicate]
                then
                    "Review"
                else
                    "OK",
            type text
        ),

    // Build a human-readable explanation for every detected issue.
    // 検出した問題を、利用者が理解しやすい文章としてIssueReasonへまとめる。
    AddedIssueReason =
        Table.AddColumn(
            AddedValidationStatus,
            "IssueReason",
            each
                Text.Combine(
                    List.RemoveNulls(
                        {
                            if [MissingCustomerID]
                            then "Customer ID is required."
                            else null,

                            if [MissingName]
                            then "Customer name is required."
                            else null,

                            if [MissingEmail]
                            then "Email address is required."
                            else null,

                            if [IsDuplicateCustomerID]
                            then "Customer ID is duplicated."
                            else null,

                            if [IsDuplicateEmail]
                            then "Email address is used by multiple records."
                            else null,

                            if [IsExactDuplicate]
                            then "An identical customer record already exists."
                            else null
                        }
                    ),
                    " "
                ),
            type text
        ),

    // Restore the original CSV row order.
    // CSV読み込み時の元の行順へ戻す。
    SortedByOriginalOrder =
        Table.Sort(
            AddedIssueReason,
            {
                {"__RowOrder", Order.Ascending}
            }
        ),

    // Remove temporary helper columns used only for calculations.
    // 重複判定などの内部計算に使用した一時列を削除する。
    RemovedHelperColumns =
        Table.RemoveColumns(
            SortedByOriginalOrder,
            {
                "__RowOrder",
                "__NormalizedEmail",
                "__CustomerIDCount",
                "__EmailCount",
                "__ExactDuplicateCount"
            }
        )
in
    RemovedHelperColumns