VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Sub runReportExample()

    ' Declare necessary objects and variables
    Dim httpRequest As Object
    Dim url As String
    Dim query As String
    Dim requestBody As String
    Dim apiKey As String
    Dim responseText As String
    Dim filePath As String
    Dim fileContent As String
    Dim jsonResponse As Object
    Dim reportNode As Object
    Dim i As Integer
    Dim userInput As String
    
    userInput = InputBox("Please enter your company ID:", "Company ID")
    
    ' CHANGE FILEPATH TO YOUR FILEPATH OF YOUR API KEY
    filePath = "filePath\apikey.txt"
    
    ' Open the text file and read the API key
    apiKey = ReadApiKeyFromFile(filePath)
    
    ' Set up the URL (replace with your API endpoint)
    url = "https://api.nexar.com/graphql"
    
    ' Set up the GraphQL query as a JSON string
    query = "{ ""query"": ""query GetReports { datRepReports(companyId: \""" & userInput & "\"") { totalCount nodes { title id fileType fileSize createdDate title } } }"" }"

    ' Create an HTTP request object
    Set httpRequest = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    
    ' Initialize and send the HTTP POST request
    With httpRequest
        .Open "POST", url, False  ' Set the HTTP method to POST and the URL
        .setRequestHeader "Content-Type", "application/json"  ' GraphQL requires JSON payload
        
        .setRequestHeader "Authorization", "Bearer " & apiKey

        ' Send the request with the query in the body
        .Send query
    End With
    
    ' Get the response text
    responseText = httpRequest.responseText
    
    
    ' Parse the JSON response using the JSON converter
    Set jsonResponse = JsonConverter.ParseJson(responseText)
    
    ' Extract the nodes from the JSON response
    Dim reports As Object
    Set reports = jsonResponse("data")("datRepReports")("nodes")
    
    ' Start writing data to Excel (starting from cell A1)
    i = 1  ' Start at row 1
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Sheet1") ' Use the desired sheet

    ' Write headers
    ws.Cells(1, 1).Value = "Title"
    ws.Cells(1, 2).Value = "ID"
    ws.Cells(1, 3).Value = "File Type"
    ws.Cells(1, 4).Value = "File Size"
    ws.Cells(1, 5).Value = "Created Date"
    
    ' Loop through each report node and write to cells
    For Each reportNode In reports
        i = i + 1
        ws.Cells(i, 1).Value = reportNode("title")
        ws.Cells(i, 2).Value = reportNode("id")
        ws.Cells(i, 3).Value = reportNode("fileType")
        ws.Cells(i, 4).Value = reportNode("fileSize")
        ws.Cells(i, 5).Value = reportNode("createdDate")
    Next reportNode
    
    MsgBox "Data written to cells successfully!"
    
    ' Clean up
    Set httpRequest = Nothing
    Set jsonResponse = Nothing
    Set reports = Nothing

End Sub

Function ReadApiKeyFromFile(filePath As String) As String
    Dim fileNum As Integer
    Dim apiKey As String
    fileNum = FreeFile ' Get the next available file number

    ' Open the file for input (reading)
    Open filePath For Input As fileNum
    
    ' Read the API key (assuming it's on the first line)
    Line Input #fileNum, apiKey
    
    ' Close the file
    Close fileNum
    
    ' Return the API key
    ReadApiKeyFromFile = apiKey
End Function
