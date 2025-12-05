# Tips and snippets

## dealing with Excel files in Sharepoint
```tmdl
					let
						Source = SharePoint.Files(SharepointSite),
						ListFilesFromFolder = Table.SelectRows(Source, each
							Text.Contains([Folder Path], SharepointFolder) and
							[Extension] = ".xlsx"),

						// Extract and transform the first sheet from each Excel file
						TransformedSheets = List.Transform(ListFilesFromFolder[Content], each
							let
								workbook = Excel.Workbook(_, null, true),
								firstSheet = Table.First(workbook)[Data],
								promoteDeaders = Table.PromoteHeaders(firstSheet, [PromoteAllScalars=true]),
								transformed = Table.TransformColumnTypes(promoteDeaders, {{"Report Date", type date}, {"Agent Name", type text}, {"Total Inbound", Int64.Type}, {"Outbound On IPCC", Int64.Type}, {"Outbound On Non-IPCC", Int64.Type}})
							in
								transformed
						),

						// Combine all transformed sheets into one table
						CombinedData = Table.Combine(TransformedSheets),
					    Augmented = Table.AddColumn(CombinedData, "Outbound", each [Outbound On IPCC] + [#"Outbound On Non-IPCC"], Int64.Type)
					in
					    Augmented
```

```tmdl
					let
					    Source = SharePoint.Files("https://flinders.sharepoint.com/sites/Dynamics_CRM", [ApiVersion = 15]),
					    GetFiles = Table.SelectRows(Source, each Text.Contains([Folder Path], "SharedData")),
					    TransfertToTables = Table.TransformColumns(GetFiles, {"Content", each Excel.Workbook(_, true)}),
					    ListSheets = Table.ExpandTableColumn(TransfertToTables, "Content", {"Name", "Data", "Item", "Kind", "Hidden"}, {"Content.Name", "Content.Data", "Content.Item", "Content.Kind", "Content.Hidden"}),
					    LoadTargetSheet = Table.SelectRows(ListSheets, each [Content.Name] = "append"){0}[Content.Data],
					    Combined = Table.Combine({Y2date, LoadTargetSheet})
					in
					    Combined
```

```tmdl
					let
					    Source = Excel.Workbook(File.Contents("coloumns.xlsx"), null, true),
					    Agent_Summary_Y2D_2025_Cleaned_Sheet = Source{[Item="Agent_Summary_Y2D_2025_Cleaned",Kind="Sheet"]}[Data],
					    #"Promoted Headers" = Table.PromoteHeaders(Agent_Summary_Y2D_2025_Cleaned_Sheet, [PromoteAllScalars=true]),
					    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Repoet Date", type date}, {"Agent Name", type text}, {"Total Inbound", Int64.Type}, {"Outbound On IPCC", Int64.Type}, {"Outbound On Non-IPCC", Int64.Type}})
					in
					    #"Changed Type"

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