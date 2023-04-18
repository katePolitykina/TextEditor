program project1;
// text chouldn't consist of any punctuation signs exept !()-:;"?'.,
{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Generics.Collections,
  System.SysUtils;
Type
  TMyArray = array of string;
  TNounsDic = record
    IP:string;
    RP:string;
    DP:string;
    VP:string;
    TP:string;
    PP:string;
  end;
  TNounsDicArray= array of TNounsDic;
procedure binsearch(mas:TNounsDicArray; var word:string; found:boolean);        // исправить вывод
var right, left, temp, mid:integer;
  begin

    left:=low(mas);
    right:=high(mas)-1;
    found:=false;
    repeat
      mid:=right-Round((right-left)/2);
      if word[1]=mas[mid].IP[1] then
        begin
          found:=true;
        end
      else
        begin
          if word[1]>mas[mid].IP[1] then
            left:=mid+1
          else
            right:=mid-1;
        end;
    until found or (left>right);
    if found then
      begin
        found:=false;
        temp:=mid;
        while ((word[1]=mas[mid].IP[1]) and (mid>=Low(mas))) and not(found) do
          begin
            if (word=mas[mid].IP)or(word=mas[mid].RP)or(word=mas[mid].DP)or(word=mas[mid].VP)or(word=mas[mid].TP)or(word=mas[mid].PP)then
              begin
                found:=true;
                word:=mas[mid].IP;
              end
            else
              mid:=mid-1;
          end;
        if not(found) then
          begin
            mid:= temp+1;
            while( word[1]=mas[mid].IP[1]) and (mid<=high(mas))and not(found) do
              begin
                if (word=mas[mid].IP)or(word=mas[mid].RP)or(word=mas[mid].DP)or(word=mas[mid].VP)or(word=mas[mid].TP)or(word=mas[mid].PP)then
                  begin
                    found:=true;
                    word:=mas[mid].IP;
                  end
                else
                  mid:=mid+1;
              end;
          end;

      end
  end;
procedure ReadFromDictionaryFile(var NounsDicArray:TNounsDicArray);
var RusNounsTxt:textfile;
    i,j:integer;
  begin
    AssignFile(RusNounsTxt, '\\Mac\Home\Documents\Курсовая работа\Text Splitter\Dictionary.txt');
    reset(RusNounsTxt);
    i:=0;
    j:=0;
    setlength(NounsDicArray,1);
    while not(Eof(RusNounsTxt)) do
      begin
        case i of
          0: begin
            readln(RusNounsTxt,NounsDicArray[j].IP);
            NounsDicArray[j].IP := UTF8Decode(NounsDicArray[j].IP);
            inc(i);
          end;
          1: begin
            readln(RusNounsTxt,NounsDicArray[j].RP);
            NounsDicArray[j].RP := UTF8Decode(NounsDicArray[j].RP);
            inc(i);
          end;
          2: begin
            readln(RusNounsTxt,NounsDicArray[j].DP);
            NounsDicArray[j].DP := UTF8Decode(NounsDicArray[j].DP);
            inc(i);
          end;
          3: begin
            readln(RusNounsTxt,NounsDicArray[j].VP);
            NounsDicArray[j].VP := UTF8Decode(NounsDicArray[j].VP);
            inc(i);
          end;
          4: begin
            readln(RusNounsTxt,NounsDicArray[j].TP);
            NounsDicArray[j].TP := UTF8Decode(NounsDicArray[j].TP);
            inc(i);
          end;
          5: begin
            readln(RusNounsTxt,NounsDicArray[j].PP);
            NounsDicArray[j].PP := UTF8Decode(NounsDicArray[j].PP);
            j:=j+1;
            setlength(NounsDicArray,j+1);
            i:=0;
          end;
        end;
      end;
      CloseFile(RusNounsTxt);
  end;

procedure DeletePunctuation(var text:string);
Procedure NoPunctuation( const punct:char; var text:string);
  var i: integer;
  begin
    i:= pos( punct, text);
    while i<>0 do
      begin
        delete(text, i, 1);
        i:= pos( punct, text);
      end;
  end;
  begin
    NoPunctuation('.', Text);
    NoPunctuation(',', Text);
    NoPunctuation(';', Text);
    NoPunctuation(':', Text);
    NoPunctuation('-', Text);
    NoPunctuation('"', Text);
    NoPunctuation('!', Text);
    NoPunctuation('?', Text);
    NoPunctuation('(', Text);
    NoPunctuation(')', Text);
    NoPunctuation('''', Text);
  end;
procedure SentenceSplit( text:ansistring; var Sentence:TmyArray);
  var i,j:integer;
  begin
    i:=1;
    j:=0;
    setLength(Sentence, 1);
    while text<>'' do
      begin
        while text[1]=' ' do
          delete( text,1,1);
        Case text[i] of
         '!', '?': begin
                     sentence[j]:=copy(text,1,i)+' ';
                     delete(text,1,i);
                     inc(j);
                     setLength(Sentence, j+1);
                     i:=1;
                   end;
        '.':       begin
                     if (text[i+1]='.') and (text[i+2]='.') then
                       begin
                         sentence[j]:=copy(text,1,i+2)+' ';
                         delete(text,1,i+2);
                       end
                     else
                       begin
                         sentence[j]:=copy(text,1,i)+' ';
                         delete(text,1,i);
                       end;
                     inc(j);
                     setLength(Sentence, j+1);
                     i:=1;
                   end;
        else
          inc(i);
        End;

      end;
  end;

procedure SplitTextIntoParagraphs(var SentenceOut:TmyArray);
  var len,highc,i,j,BegOfWord,NumbOfWordsRepeated,PrevNumbOfWordsRepeated, PrevPrevNumbOfWordsRepeated :integer;
      temp:String;
      IsWordInDic:boolean;
      WordCount: TDictionary<string, Integer>;
      Sentence:TMyArray;
      NounsDicArray:TNounsDicArray;


begin
ReadFromDictionaryFile(NounsDicArray);
sentence:=copy(SentenceOut);
WordCount := TDictionary<string, Integer>.Create;
PrevNumbOfWordsRepeated:=0;
PrevPrevNumbOfWordsRepeated:=0;
  for I := Low(Sentence) to High(Sentence) do
    begin
      DeletePunctuation(sentence[i]);
      PrevPrevNumbOfWordsRepeated:= PrevNumbOfWordsRepeated;
      PrevNumbOfWordsRepeated:=NumbOfWordsRepeated;
      j:=0;
      len:=length(sentence[i]) ;
      highc:= high(sentence[i]);
      while highc<>0 do
        begin
          BegOfWord:=j+1;
          while sentence[i][j]<>' ' do
            inc(j);
          temp:=copy(sentence[i],BegOfWord,j-BegOfWord);
          delete(sentence[i],BegOfWord,j-BegOfWord+1);
          j:=BegOfWord-1;
          binsearch(NounsDicArray,temp,IsWordInDic);
          if IsWordInDic then
            begin
              if WordCount.ContainsKey(temp) then
                begin
                  NumbOfWordsRepeated:= NumbOfWordsRepeated + WordCount[temp];
                  WordCount[temp] := WordCount[temp] + 1 ;
                end
              else
                WordCount.Add(temp, 1);
              if (PrevNumbOfWordsRepeated<PrevPrevNumbOfWordsRepeated) and((NumbOfWordsRepeated-PrevNumbOfWordsRepeated)<2) then
                begin
                  sentenceOut[i-2]:= sentenceOut[i-2]+ #1013;
                  Wordcount.free;
                  WordCount := TDictionary<string, Integer>.Create;
                end;
            end;
        end;



    end;
end;
var FirstSampleText:string;
    Sentence:TMyArray;
    i:integer;
begin
FirstSampleText :='Катя пришла со школы. Катя 4 года. Катя крутая. Мама готовит суп. Мама устала.';
SentenceSplit(FirstSampleText,Sentence);
SplitTextIntoParagraphs(Sentence);
for i:=low(Sentence) to high(Sentence) do
  begin
    write(sentence[i]);
  end;



end.
