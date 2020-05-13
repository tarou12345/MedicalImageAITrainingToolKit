%%
clear

%%
load('gTruthCellMoving.mat')
%load('gTruth.mat')

%%
A = GTruthConverter(gTruth);
% B = SeparateLabelDef(gTruth);

%%
% セグメント

imshow(A.getSegmentFusionImage(1,1))

%% 動画を４Dに読み込み
movie4d = ReadMovie2Memory('cellMoving.avi');

%% Rect 
A.viewRectedImage(1,1)
A.viewRectInsertedImage(1,1)

%% view
A.viewRectLine(1,1);

%% 画像にラインを書き込み

I = A.getOriginalImage(1);
Iinserted = insertShape(I, ...
    'Line', centerListsCell, 'LineWidth', 5, 'Color', colorMapVal*255);
imshow(Iinserted)

%%