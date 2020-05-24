%%
clear

%%
load('gTruth')
A = GTruthConverter(gTruth);

%%
frame = 1;
I = A.getOriginalImage(frame);
O = OcrOfImage(I);

%% 認識した単語をすべて画像に挿入
Ia = O.insertAllWords2Image;
imshow(Ia);

%% 認識した単語をすべて表示
O.showAllWordsAtImage;

%% 特定のIDを画像に挿入
wordId = 1;
Ia = O.insertWordsById2Image(wordId);
imshow(Ia)

%% 特定のIDを画像に挿入
% Idのリストでもok
wordId = [1 2 5 19];
Ia = O.insertWordsById2Image(wordId);
imshow(Ia)

%% 特定のIDを画像に表示
O.showWordsAtImage(wordId);

%% 特定の文字の検索
text = 'okayama';
isExist = O.isExist(text)

%% 特定の文字の有り無しインデックス
text = 'okayama';
indexes = O.detectWordsAndReturnLogical(text)

%% 特定の文字のId
text = 'a';
id = O.detectWordsId(text)

%% 特定の文字を含むidの数
text = 'a';
num = O.detectWordsAndCountNum(text)

%% 特定の文字を含むBBox
text = 'a';
boundingBox = O.detectWordsAndReturnBoudingBoxes(text)

%% 特定の文字を含むidとBBox
text = 'a';
[id boundingBox] = O.detectWordsAndProperties(text)

%% 特定の文字を検索して画像に挿入
text = 'a';
I = O.detectWordsAndInsertWords2Image(text);
imshow(I);

%% 特定の文字を検索して画像に表示
text = 'okayama';
O.showDetectWordsAndInsertWords2Image(text)

%% 特定の文字を検索して画像に表示
text = 'a';
O.showDetectWordsAndInsertWords2Image(text)

