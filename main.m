%%
load('gTruth.mat')
%%
A = GTruthConverter(gTruth);
% B = SeparateLabelDef(gTruth);

%%
% セグメント

imshow(A.getSegmentFusionImage(1,1))

%% Rect 
A.viewRectedImage(1,1)
A.viewRectInsertedImage(1,1)

%% view
A.viewRectLine(1);

%% Rect Center
% ToDo：　これはラベルごとに存在するので別のクラスに分けたほうが良いかもしれない
labelId = 1; 

% 設定
numOfLine = 0; % 線の数
stateOfLine = 0; % 前回、点があったかどうか
centerList = []; % 線の点のリスト [x1,y1,x2,y2, ...]
centerListsCell = {}; % 線のセル {[x1,y1,..],[x2,y2,...]}
centerListWithNull = zeros(1,2);

for i=1:A.numOfImages
   center = A.getRectCenter(i,labelId);
   if isempty(center)
       centerListWithNull(i,:) = [-1 -1 ];
   else
       centerListWithNull(i,1) = center(1);
       centerListWithNull(i,2) = center(2);
   end
   
   if and((stateOfLine == 0), not(isempty(center))) 
       % 前回「点なし」、今回「点あり」の時、新しい線の開始とみなす
       numOfLine = numOfLine + 1;
       % 1本目の線の開始以外の時に、前回の線(n-1)を記録してリストを初期化
       if numOfLine ~= 1
           centerListsCell(numOfLine-1) = {centerList};
           centerList = [];
       end
   end
   
   % 「点あり」であればcenterListに追加記録
   if not(isempty(center))
       centerList = [ centerList, center];
   end
   
   % 「点有り：１」「点無し：０」状態を記録
   stateOfLine = ~isempty(center);
       
end

% 点リストが残っていればセルに追加記録
if ~isempty(centerList)
    centerListsCell(numOfLine) = {centerList};
end

%% 画像にラインを書き込み

I = A.getOriginalImage(1);
Iinserted = insertShape(I, ...
    'Line', centerListsCell, 'LineWidth', 5, 'Color', colorMapVal*255);
imshow(Iinserted)
