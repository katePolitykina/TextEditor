program TextSplitter;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Generics.Collections,
  System.SysUtils;

function SplitTextIntoParagraphs(const Text: string): TArray<string>;
var
  Words: TArray<string>;
  WordCount: TDictionary<string, Integer>;
  Paragraphs: TList<string>;
  Paragraph: string;
  Word: string;
  i: Integer;
begin
  // Split the text into words
  Words := Text.Split([' ']);


  // Count the frequency of occurrence of each word
  WordCount := TDictionary<string, Integer>.Create;
  try
    for Word in Words do
    begin
      if WordCount.ContainsKey(Word) then
        WordCount[Word] := WordCount[Word] + 1
      else
        WordCount.Add(Word, 1);
    end;

    // Initialize the paragraphs list
    Paragraphs := TList<string>.Create;
    try
      // Split the text into paragraphs based on the frequency of occurrence of each word
      Paragraph := '';
      for i := Low(Words) to High(Words) do
      begin
        if (WordCount[Words[i]] < 3) and (Paragraph <> '') then // Split the paragraph if the word occurs less than 3 times
        begin
          Paragraphs.Add(Paragraph.Trim);
          Paragraph := '';
        end;
        Paragraph := Paragraph + Words[i] + ' ';
      end;
      if Paragraph <> '' then
        Paragraphs.Add(Paragraph.Trim);

      // Convert the paragraphs list to an array
      Result := Paragraphs.ToArray;
    finally
      Paragraphs.Free;
    end;
  finally
    WordCount.Free;
  end;
end;
procedure ShowListContents(myList:TList<string>);
var
  i : Integer;
begin
  // � ��������� ����� ������
  for i := 0 to myList.Count-1 do
  begin
    Writeln(myList[i]);
  end;
end;
var FirstSampleText:string;
    i : integer;
    SplittedText:TArray<string>;


begin
FirstSampleText :='���� ������ �� �����. ���� 4 ����. ���� ������. ���� ������� ���. ���� ������. ';
SplittedText:=SplitTextIntoParagraphs(FirstSampleText);
for i:= low(SplittedText) to high(SplittedText) do
  begin
    writeln(SplittedText[i]);
  end;
readln;
end.
