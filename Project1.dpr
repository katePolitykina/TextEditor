program project1;
// text chouldn't consist of any punctuation signs exept !()-:;"?'.,
{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Generics.Collections,
  System.SysUtils;

Procedure DeletePunctuation( const punct:char; var text:string);
  var i: integer;
  begin
    i:= pos( punct, text);
    while i<>0 do
      begin
        delete(text, i, 1);
        i:= pos( punct, text);
      end;
  end;
procedure NoPunctuation(var text:string);
  begin
    DeletePunctuation('.', Text);
    DeletePunctuation(',', Text);
    DeletePunctuation(';', Text);
    DeletePunctuation(':', Text);
    DeletePunctuation('-', Text);
    DeletePunctuation('"', Text);
    DeletePunctuation('!', Text);
    DeletePunctuation('?', Text);
    DeletePunctuation('(', Text);
    DeletePunctuation(')', Text);
    DeletePunctuation('''', Text);
  end;
function SplitTextIntoParagraphs(const Text: string): TArray<string>;
var
 // Words: TArray<string>;
  Words: TArray<string>;
  TextNoPunctuation: String;
  WordCount: TDictionary<string, Integer>;
  Paragraphs: TList<string>;
  Paragraph: Ansistring;
  Word: string;
  Sentence: string;
  i: Integer;
  Sentences: TArray<string>;


begin
  TextNoPunctuation:=text;     // Create copy of text with no punctuation
  NoPunctuation(TextNoPunctuation);
  // Split the text into words
   Words := TextNoPunctuation.Split([' ']);
   Sentences := Text.Split(['. ']);
    for Sentence in Sentences do
    begin
      writeln( Sentence);
    end;

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
        if (WordCount[Words[i]] <3) and (Paragraph <> '') then // Split the paragraph if the word occurs less than 3 times
        begin
          Paragraphs.Add(Paragraph);
          Paragraph := '';
        end;
        Paragraph := Paragraph + Words[i] + ' ';
      end;
      if Paragraph <> '' then
        Paragraphs.Add(Paragraph);

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
