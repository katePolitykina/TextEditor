program project1;
// text chouldn't consist of any punctuation signs exept !()-:;"?'.,
{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Generics.Collections,
  System.SysUtils;

Const firstDictionaryLength=10;
Type
  TMyArray = array of string;
  TNounsDic = array [1..12] of string;
  TNounsDicArray= array of TNounsDic;
procedure binsearch(mas:TNounsDicArray; var word:string; var found:boolean);        // исправить вывод
// поиск слова в словаре и присваивание word именительного падежа
var right, left, temp, mid, i:integer;
    DoContinue:boolean;
  begin
    left:=low(mas);
    right:=high(mas);
    found:=false;
    repeat
      mid:=right-Round((right-left)/2);
      if word[1]=mas[mid][1][1] then
        begin
          found:=true;
        end
      else
        begin
          if word[1]>mas[mid][1][1] then
            left:=mid+1
          else
            right:=mid-1;
        end;
    until found or (left>right);
    if found then
      begin
        found:=false;
        temp:=mid;
        DoContinue:=true;
        while DoContinue and (mid>=Low(mas))do
          begin
            if word[1]<>mas[mid][1][1] then
              DoContinue:=false
            else
              begin
                i:=1;
                while (i<13) and DoContinue do
                  begin
                    if word=mas[mid][i] then
                      begin
                        found:=true;
                        DoContinue:=false;
                        word:=mas[mid][1];
                      end;
                  end;
                  dec(mid);
              end;
          end;
        if not(found) then
          begin
            DoContinue:=true;
            mid:= temp+1;
            while DoContinue and (mid<=high(mas))do
              begin
                if word[1]<>mas[mid][1][1] then
                  DoContinue:=false
                else
                  begin
                    i:=1;
                    while (i<13) and DoContinue do
                      begin
                        if word=mas[mid][i] then
                          begin
                            found:=true;
                            DoContinue:=false;
                            word:=mas[mid][1];
                          end;
                      end;
                    inc(mid);
                  end;
              end;
          end;

      end
  end;
procedure ReadFromDictionaryFile(var NounsDicArray:TNounsDicArray);
// запись в массив словаря
var RusNounsTxt:textfile;
    i,j:integer;
    DoContinue:boolean;
  begin
    AssignFile(RusNounsTxt, '\\Mac\Home\Documents\Курсовая работа\Text Splitter\Dictionary.txt');
    reset(RusNounsTxt);
    i:=1;
    setlength(NounsDicArray,firstDictionaryLength);
    j:=Low(NounsDicArray);;
    setlength(NounsDicArray,firstDictionaryLength);
    while not(Eof(RusNounsTxt)) do
      begin
        if j>high(NounsDicArray)then
          setlength(NounsDicArray,2*length(NounsDicArray));
        for i:=1 to 12  do
        begin
            readln(RusNounsTxt,NounsDicArray[j][i]);
            NounsDicArray[j][i] := UTF8Decode(NounsDicArray[j][i]);
        end;
        inc(j);
      end;
    setlength(NounsDicArray,j);
    CloseFile(RusNounsTxt);
  end;
procedure DeletePunctuation(var text:string);
// Удаление всех знаков пунктуации
Procedure NoPunctuation( const punct:char; var text:string);
// Удаление определенного знака пунктуации
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
// разделение текста на массив предложений
  var i,j,textlength:integer;
  begin       // удалить последние пробелы
    textlength:=length(text);
    while text[textlength]=' ' do
      begin
        delete( text,textlength,1);
        textlength:=textlength-1;
      end;

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
                     if length(text)>i then
                       begin
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
                       end
                     else
                       begin
                         sentence[j]:=copy(text,1,i)+' ';
                         delete(text,1,i);
                       end;
                     inc(j);
                     setLength(Sentence, j+1);
                     i:=1;
                    end
        else
          inc(i);
        End;

      end;
  end;

procedure SplitTextIntoParagraphs(var SentenceOut:TmyArray);
// разделение текста на параграфы
  var i,j,BegOfWord,NumbOfWordsRepeated,PrevNumbOfWordsRepeated,
      PrevPrevNumbOfWordsRepeated, IndexOfNewPassageSentence :integer;
      temp:String;
      IsWordInDic:boolean;
      WordCount: TDictionary<string, Integer>;
      Sentence:TMyArray;
      NounsDicArray:TNounsDicArray;




begin // Перезаписать буквы в малый шрифт
ReadFromDictionaryFile(NounsDicArray);       // запись в массив словаря
sentence:=copy(SentenceOut);      // копия предложений с пункт
WordCount := TDictionary<string, Integer>.Create;
PrevNumbOfWordsRepeated:=0;
PrevPrevNumbOfWordsRepeated:=0;
IndexOfNewPassageSentence:=0;
  for I := Low(Sentence) to High(Sentence) do
    begin
      DeletePunctuation(sentence[i]);
      PrevPrevNumbOfWordsRepeated:= PrevNumbOfWordsRepeated;
      PrevNumbOfWordsRepeated:=NumbOfWordsRepeated;
      j:=0;
      while sentence[i]<>'' do
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
            end;

        end;
      if (IndexOfNewPassageSentence>2 ) and(PrevNumbOfWordsRepeated<=PrevPrevNumbOfWordsRepeated) and((NumbOfWordsRepeated-PrevNumbOfWordsRepeated)<2) then
        begin
          sentenceOut[i-2]:= sentenceOut[i-2]+ #10;// #10- перевод строки
          Wordcount.free;
          IndexOfNewPassageSentence:=0;
          WordCount := TDictionary<string, Integer>.Create;
        end;
      inc(IndexOfNewPassageSentence);
    end;
end;
var FirstSampleText,SampleTextLine:string;
    Sentence:TMyArray;
    i:integer;
    SampleText:textfile;

begin
  AssignFile(SampleText, '\\Mac\Home\Documents\Курсовая работа\Тексты для проверки\Тексты уровня А1\Моя семья.txt');
  reset(SampleText);
  while not(Eof(SampleText)) do
    begin
      readln(SampleText,SampleTextLine);
      FirstSampleText:=FirstSampleText+SampleTextLine;
    end;
    FirstSampleText:= UTF8Decode(FirstSampleText);
    CloseFile(SampleText);
 // FirstSampleText :='У меня большая семья из шести человек: я, мама, папа, старшая сестра, бабушка и дедушка. Мы живем все вместе с собакой Бимом и кошкой Муркой в большом доме в деревне. Мой папа встает раньше всех, потому что ему рано на работу. Он работает доктором. Обычно бабушка готовит нам завтрак. Я обожаю овсяную кашу, а моя сестра Аня – блины. После завтрака мы собираемся и идем в школу. Моя сестра учится в пятом классе, а я – во втором. Мы любим учиться и играть с друзьями. Больше всего я люблю географию. Когда мы приходим домой из школы, мы смотрим телевизор, а потом ужинаем и делаем уроки. Иногда мы помогаем бабушке и маме в огороде, где они выращивают овощи и фрукты.';
  SentenceSplit(FirstSampleText,Sentence);
  SplitTextIntoParagraphs(Sentence);
  for i:=low(Sentence) to high(Sentence) do
    begin
      write(sentence[i]);
    end;
  readln;
end.
