# Tips and snippets

## Dealing with Excel files saved in Sharepoint
Power BI can access files saved in Sharepoint site. Commonly files are organised in document libraries.

### Read files

Sharepoint has document libraries, folder (?) and list. There are SharePoint connectors in [Power Query m code](https://learn.microsoft.com/en-us/powerquery-m/) can be used:  
- `SharePoint.Files`  
Returns a table containing a row for each document found at the specified SharePoint site, url, and subfolders. Each row contains properties of the folder or file and a link to its content. The result is a flat table of all files (recursively) across the site (document libraries & folders). Not suitable for sites with lots of libraries/files. 
- `SharePoint.Contents`  
Returns a table containing a row for each folder and document found at the specified SharePoint site, url. Each row contains properties of the folder or file and a link to its content. The result is a hierarchical view (folders, libraries, lists).
- `SharePoint.Tables`  
Returns a table containing a row for each List item found at the specified SharePoint list, url. Each row contains properties of the List. 

#### Load everything from a site with `SharePoint.Files`
```tmdl
let
    Source = SharePoint.Files(Site),
	// All files and folders have been loaded, filter them
    SpreadSheets = Table.SelectRows(Source, each Text.Contains([Folder Path], "XXX/YYY") and [Extension] = ".xlsx")
in
    SpreadSheets
```

#### Load folders and files by steps with `SharePoint.Contents`
```tmdl
let
	// one step one level
    Source = SharePoint.Contents(Site),
    Documents = Source{[Name="Documents"]}[Content],
    TF = Documents{[Name=TargetFolder]}[Content],
	// one specific file
    SpreadSheet = TF{[Name=ExcelFile]}[Content],
	// all xlsx files
    // SpreadSheets = Table.SelectRows(TF, each [Extension] = ".xlsx")

in
    SpreadSheet
```

### Handling Excel files, workbooks, sheets
#### 1. Expand sheets to the file table 
```tmdl
let
	// ...
	// transform Content column from Binary to Excel Workbook
	ColumnTransformed = Table.TransformColumns(SpreadSheets, {"Content", each Excel.Workbook(_, true)}),
	// Each Workbook has five columns: Name, Data, Item, Kind and Hidden
	// By expanding Content column, each spread sheets are flatted with those columns, include the hidden sheet DefinedName  
	PivotSheetTable = Table.ExpandTableColumn(ColumnTransformed, "Content", {"Name", "Data"}, {"Content.Name", "Content.Data"}),
	// Filter sheets in rows
	SelectedSheets = Table.SelectRows(PivotSheetTable, each [Content.Name] = SelectedSheet)[Content.Data],
	Combined = Table.Combine(SelectedSheets)
	// or combine with an existing table
	// Combined = Table.Combine({AnotherTable, SelectedSheets})
in
	Combined
```

#### 2. Extract files to a list
```tmdl
let
	// ...
    Workbooks = List.Transform(SpreadSheets[Content], each Excel.Workbook(_, true)),
    SelectedSheets = List.Transform(Workbooks, each Table.SelectRows(_, each [Name] = SelectedSheet){0}[Data]),
    Combined = Table.Combine(SelectedSheets)
in
    Combined
```

### Handle data in Spreadsheets
```tmdl
let
	// Extract and transform the first sheet from each Excel file
	FirstSheets = List.Transform(SpreadSheets[Content], each
		let
			workbook = Excel.Workbook(_, true),
			firstSheet = Table.First(workbook)[Data],
			transformed = Table.TransformColumnTypes(firstSheet, {{"Date", type date}, {"Name", type text}, {"Count1", Int64.Type}, , {"Count2", Int64.Type}})
		in
			transformed
	),

	// Combine all transformed sheets into one table
	CombinedData = Table.Combine(FirstSheets),
	// More processes:
	Augmented = Table.AddColumn(CombinedData, "Total", each [Count1] + [Count2], Int64.Type)
in
	Augmented
```

## Small multiples
When dealing with data from multiple columns, measures, or even tables, Power BI’s line chart does not allow multiple measures with Legend for YoY comparison—only one measure series can be used when Legend is applied.
To solve this, use the Small Multiples + Selector Table pattern. This avoids creating unpivoted data tables and keeps the model dynamic.

Steps:

- Create a calculated selector table (MeasureID, MeasureName).
```tmdl
Activity Selector = 
DATATABLE(
    "MeasureID", INTEGER,
    "MeasureName", STRING,
    {
        { 1, "Inbound Call" },
        { 2, "Outbound Call" },
        { 3, "Chat" },
        { 4, "Sequence Activity" }
    }
)
```
- Create a SWITCH measure mapping MeasureID → actual measures.
```tmdl
Selected Measure Value = 
VAR sid = SELECTEDVALUE('Activity Selector'[MeasureID])
RETURN
SWITCH(
    TRUE(),
    sid = 1, [Total Inbound],
    sid = 2, [Total Outbound],
    sid = 3, [Total Chat],
    sid = 4, [Completed Activities],
    BLANK()
)
```
- In the line chart:
    - X-axis: Date
    - Values (Y-axis): The SWITCH measure
    - Small multiples: MeasureName from the selector table
    - Legend: Year (for YoY comparison, especially with Month on X-axis)
- Adjust formatting:
    - Turn Shared Y-axis OFF if ranges differ (trade-off: no magnitude comparison).
    - Sort MeasureName by MeasureID for custom order.

This approach keeps the report dynamic, clean, and interactive without creating a huge unpivoted table.